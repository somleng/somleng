class AccountBillingPolicy
  attr_reader :rating_engine_client

  def initialize(**options)
    @rating_engine_client = options.fetch(:rating_engine_client) { RatingEngineClient.new }
  end

  def good_standing?(account:, usage:, category:, destination:)
    return true unless account.billing_enabled?
    return false unless account.tariff_plan_subscriptions.exists?(category:)

    rating_engine_client.sufficient_balance?(
      account,
      usage:,
      category:,
      destination:
    )
  end
end
