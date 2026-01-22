class RatingEngineClient
  attr_reader :client

  TENANT = "cgrates.org"
  LOAD_ID = "somleng.org"
  BALANCE_TYPE = "*monetary"
  ROUNDING_DECIMALS = 4
  ROUNDING_METHOD = "*up"
  RATE_UNIT = "60s"
  RATE_INCREMENT = "60s"

  RATE_UNITS = {
    call: {
      unit: "60s",
      increment: "60s"
    },
    message: {
      unit: "1",
      increment: "1"
    }
  }

  CDR = Data.define(:id, :account_id, :cost, :balance_transaction_id)

  def initialize(**options)
    @client = options.fetch(:client) { CGRateS::Client.new }
  end

  class APIError < StandardError; end
  class InsufficientBalanceError < APIError; end

  def account_balance(account)
    response = handle_request do
      client.get_account(
        tenant: TENANT,
        account: account.id,
      )
    end

    value = response.result.dig("BalanceMap", "*monetary", 0, "Value")
    value = 0 if value.blank?

    Money.from_amount(value, account.billing_currency)
  end

  def upsert_destination_group(destination_group)
    handle_request do
      client.set_tp_destination(
        tp_id: destination_group.carrier_id,
        id: destination_group.id,
        prefixes: destination_group.prefixes.pluck(:prefix)
      )
    end
  end

  def upsert_tariff_schedule(tariff_schedule)
    handle_request do
      destination_tariffs = tariff_schedule.destination_tariffs.includes(:tariff)

      destination_tariffs.each do |destination_tariff|
        tariff = destination_tariff.tariff
        rate_unit = RATE_UNITS.fetch(tariff.category.to_sym)

        client.set_tp_rate(
          tp_id: tariff_schedule.carrier_id,
          id: tariff.id,
          rate_slots: [
            {
              rate: tariff.rate.to_f,
              rate_unit: rate_unit.fetch(:unit),
              rate_increment: rate_unit.fetch(:increment)
            }
          ]
        )
      end

      client.set_tp_destination_rate(
        tp_id: tariff_schedule.carrier_id,
        id: tariff_schedule.id,
        destination_rates: destination_tariffs.map do |destination_tariff|
          {
            rounding_decimals: ROUNDING_DECIMALS,
            rate_id: destination_tariff.tariff_id,
            destination_id: destination_tariff.destination_group_id,
            rounding_method: ROUNDING_METHOD
          }
        end
      )
    end
  end

  def destroy_tariff_schedule(tariff_schedule)
    handle_request do
      client.remove_tp_destination_rate(
        tp_id: tariff_schedule.carrier_id,
        id: tariff_schedule.id,
      )
    end
  end

  def upsert_tariff_plan(tariff_plan)
    handle_request do
      client.set_tp_rating_plan(
        tp_id: tariff_plan.carrier_id,
        id: tariff_plan.id,
        rating_plan_bindings: tariff_plan.tiers.map do |tier|
          {
            weight: tier.weight.to_f,
            timing_id: "*any",
            destination_rates_id: tier.schedule_id
          }
        end
      )
    end
  end

  def destroy_tariff_plan(tariff_plan)
    handle_request do
      client.remove_tp_rating_plan(
        tp_id: tariff_plan.carrier_id,
        id: tariff_plan.id,
      )
    end
  end

  def upsert_account(account)
    handle_request do
      account.tariff_plan_subscriptions.each do |subscription|
        client.set_tp_rating_profile(
          tp_id: account.carrier_id,
          load_id: LOAD_ID,
          category: subscription.category,
          tenant: TENANT,
          subject: account.id,
          rating_plan_activations: [
            {
              activation_time: subscription.created_at.iso8601,
              rating_plan_id: subscription.plan_id
            }
          ]
        )
      end

      subscribed_categories = account.tariff_plan_subscriptions.pluck(:category)
      all_categories = TariffPlanSubscription.category.values
      (all_categories - subscribed_categories).each do |category|
        client.remove_tp_rating_profile(
          tp_id: account.carrier_id,
          load_id: LOAD_ID,
          category:,
          tenant: TENANT,
          subject: account.id,
        )
      end

      client.set_account(
        tenant: TENANT,
        account: account.id,
      )
    end
  end

  def destroy_account(account)
    handle_request do
      client.remove_account(
        tenant: TENANT,
        account: account.id,
      )
    end
  end

  def refresh_carrier_rates(carrier)
    handle_request do
      client.load_tariff_plan_from_stor_db(
        tp_id: carrier.id,
      )
    end
  end

  def update_account_balance(balance_transaction)
    handle_request do
      params = {
        tenant: TENANT,
        account: balance_transaction.account_id,
        balance_type: BALANCE_TYPE,
        value: balance_transaction.amount.abs.to_f,
        balance: {
          id: balance_transaction.account_id,
        },
        cdrlog: true,
        action_extra_data: {
          balance_transaction_id: balance_transaction.id
        }
      }

      if balance_transaction.credit?
        client.add_balance(**params)
      else
        client.debit_balance(**params)
      end
    end
  end

  def create_message_charge(message)
    handle_request do
      client.process_external_cdr(
        category: message.tariff_category,
        request_type: "*#{message.account.billing_mode}",
        tor: "*message",
        tenant: TENANT,
        account: message.account_id,
        destination: message.to,
        answer_time: message.created_at.iso8601,
        setup_time: message.created_at.iso8601,
        usage: message.segments,
        origin_id: message.id
      )

      response = client.get_cdrs(
        tenants: [ TENANT ],
        origin_ids: [ message.id ]
      )

      cdr = response.result[0]
      if cdr.fetch("Cost").negative?
        raise InsufficientBalanceError if cdr.fetch("ExtraInfo") == "MAX_USAGE_EXCEEDED"

        raise APIError.new(cdr.fetch("ExtraInfo"))
      end
    end
  end

  def fetch_cdrs(last_id:, limit:)
    response = client.get_cdrs(
      tenants: [ TENANT ],
      order_by: "OrderID",
      extra_args: { "OrderIDStart" => last_id.to_i },
      limit:
    )

    response.result.map do |cdr|
      CDR.new(
        id: cdr.fetch("OrderID"),
        account_id: cdr.fetch("Account"),
        cost: cdr.fetch("Cost"),
        balance_transaction_id: cdr.dig("ExtraFields", "balance_transaction_id")
      )
    end
  rescue CGRateS::Client::NotFoundError
    []
  rescue CGRateS::Client::APIError => e
    raise APIError.new(e.message)
  end

  private

  def handle_request(&)
    yield
  rescue CGRateS::Client::APIError => e
    raise APIError.new(e.message)
  end
end
