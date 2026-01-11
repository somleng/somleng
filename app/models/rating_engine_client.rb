class RatingEngineClient
  attr_reader :client

  def initialize(**options)
    @client = options.fetch(:client) { CGRateS::Client.new }
  end

  class APIError < StandardError; end

  def upsert_destination_group(destination_group)
    client.set_tp_destination(
      tp_id: destination_group.carrier_id,
      id: destination_group.id,
      prefixes: destination_group.prefixes.pluck(:prefix)
    )
  end

  def upsert_tariff_schedule(tariff_schedule)
    destination_tariffs = tariff_schedule.destination_tariffs.includes(:tariff)

    destination_tariffs.each do |destination_tariff|
      tariff = destination_tariff.tariff
      client.set_tp_rate(
        tp_id: tariff_schedule.carrier_id,
        id: tariff.id,
        rate_slots: [
          { rate: tariff.rate.to_f, rate_unit: "60s", rate_increment: "60s" }
        ]
      )
    end

    client.set_tp_destination_rate(
      tp_id: tariff_schedule.carrier_id,
      id: tariff_schedule.id,
      destination_rates: destination_tariffs.map do |destination_tariff|
        {
          rounding_decimals: 4,
          rate_id: destination_tariff.tariff_id,
          destination_id: destination_tariff.destination_group_id,
          rounding_method: "*up"
        }
      end
    )
  end

  def destroy_tariff_schedule(tariff_schedule)
    client.remove_tp_destination_rate(
      tp_id: tariff_schedule.carrier_id,
      id: tariff_schedule.id,
    )
  end

  def upsert_tariff_plan(tariff_plan)
    client.set_tp_rating_plan(
      tp_id: tariff_plan.carrier_id,
      id: tariff_plan.id,
      rating_plan_bindings: tariff_plan.tiers.map do |tier|
        { weight: tier.weight.to_f, timing_id: "*any", destination_rates_id: tier.schedule_id }
      end
    )
  end

  def destroy_tariff_plan(tariff_plan)
    client.remove_tp_rating_plan(
      tp_id: tariff_plan.carrier_id,
      id: tariff_plan.id,
    )
  end

  def upsert_account_tariff_plan_subscriptions(account)
    account.tariff_plan_subscriptions.each do |subscription|
      client.set_tp_rating_profile(
        tp_id: account.carrier_id,
        load_id: "somleng.org",
        category: subscription.category,
        tenant: "cgrates.org",
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
        load_id: "somleng.org",
        category:,
        tenant: "cgrates.org",
        subject: account.id,
      )
    end

    client.set_account(
      tenant: "cgrates.org",
      account: account.id,
    )
  end

  def destroy_account(account)
    client.remove_account(
      tenant: "cgrates.org",
      account: account.id,
    )
  end

  private

  def make_request
    yield
  rescue CGRateS::APIError => e
    raise APIError.new(e.message)
  end
end
