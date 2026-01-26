class RatingEngineClient
  attr_reader :client

  LOAD_ID = "somleng.org"
  BALANCE_TYPE = "*monetary"
  ROUNDING_DECIMALS = 5
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

  CDR = Data.define(:id, :origin_id, :category, :account_id, :cost, :balance_transaction_id, :extra_info, :success?)

  CDR_ERROR_CODES = {
    "MAX_USAGE_EXCEEDED" => :insufficient_balance,
    "RATING_PLAN_NOT_FOUND" => :subscription_disabled
  }

  def initialize(**options)
    @client = options.fetch(:client) { AppSettings.stub_rating_engine? ? CGRateS::FakeClient.new : CGRateS::Client.new }
  end

  class APIError < StandardError; end
  class FailedCDRError < APIError
    attr_reader :error_code

    def initialize(message, error_code:)
      super(message)
      @error_code = error_code
    end
  end

  def account_balance(account)
    response = handle_request do
      client.get_account(
        tenant: account.carrier_id,
        account: account.id,
      )
    end

    value = response.result.dig("BalanceMap", BALANCE_TYPE, 0, "Value")
    value = 0 if value.blank?

    Money.new(value, account.billing_currency)
  end

  def upsert_charging_profile(carrier)
    handle_request do
      client.set_charger_profile(
        tenant: carrier.id,
        id: carrier.id
      )
    end
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
              rate: tariff.rate_cents.to_f,
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
          tenant: account.carrier_id,
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
          tenant: account.carrier_id,
          subject: account.id,
        )
      end

      client.set_account(
        tenant: account.carrier_id,
        account: account.id,
      )
    end
  end

  def destroy_account(account)
    handle_request do
      client.remove_account(
        tenant: account.carrier_id,
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
        tenant: balance_transaction.carrier_id,
        account: balance_transaction.account_id,
        balance_type: BALANCE_TYPE,
        value: balance_transaction.amount_cents.abs,
        balance: {
          id: balance_transaction.account_id
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
        tenant: message.carrier_id,
        account: message.account_id,
        destination: message.to,
        answer_time: message.created_at.iso8601,
        setup_time: message.created_at.iso8601,
        usage: message.segments.to_s,
        origin_id: message.id
      )

      response = client.get_cdrs(origin_ids: [ message.id ])

      cdr = build_cdr(response.result[0])
      return if cdr.success?

      raise FailedCDRError.new(cdr.extra_info, error_code: CDR_ERROR_CODES.fetch(cdr.extra_info)) if CDR_ERROR_CODES.key?(cdr.extra_info)
      raise APIError.new(cdr.extra_info)
    end
  end

  def fetch_cdrs(last_id:, limit:)
    response = client.get_cdrs(
      not_costs: [ -1, 0 ],
      order_by: "OrderID",
      extra_args: { "OrderIDStart" => last_id.to_i },
      limit:
    )

    response.result.map { |it| build_cdr(it) }
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

  def build_cdr(response)
    cost = response.fetch("Cost")
    CDR.new(
      id: response.fetch("OrderID"),
      account_id: response.fetch("Account"),
      cost:,
      balance_transaction_id: response.dig("ExtraFields", "balance_transaction_id"),
      extra_info: response.fetch("ExtraInfo"),
      origin_id: response.fetch("OriginID"),
      category: response.fetch("Category"),
      success?: !cost.negative?
    )
  end
end
