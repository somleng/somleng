class AccountBillingPolicy
  attr_reader :credit_validator, :error_code

  def initialize(**options)
    @credit_validator = options.fetch(:credit_validator) { RatingEngineClient.new }
  end

  def valid?(account:, usage:, category:, destination:)
    return true unless account.billing_enabled?

    if !account.tariff_plan_subscriptions.exists?(category:)
      @error_code = :subscription_disabled
    elsif !credit_validator.sufficient_balance?(account, usage:, category:, destination:)
      @error_code = :insufficient_balance
    end

    @error_code.blank?
  end
end
