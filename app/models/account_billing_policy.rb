class AccountBillingPolicy
  attr_reader :credit_validator, :error_code

  def initialize(**options)
    @credit_validator = options.fetch(:credit_validator) { RatingEngineClient.new }
  end

  def valid?(interaction:)
    return true unless interaction.account.billing_enabled?

    if !interaction.account.tariff_plan_subscriptions.exists?(category: interaction.tariff_schedule_category)
      @error_code = :subscription_disabled
    elsif !credit_validator.sufficient_balance?(interaction)
      @error_code = :insufficient_balance
    end

    @error_code.blank?
  end
end
