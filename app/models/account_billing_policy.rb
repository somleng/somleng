class AccountBillingPolicy
  attr_reader :credit_validator, :tariff_calculator, :error_code

  def initialize(**options)
    @credit_validator = options.fetch(:credit_validator) { RatingEngineClient.new }
    @tariff_calculator = options.fetch(:tariff_calculator) { TariffCalculator.new }
  end

  def valid?(interaction:)
    return true unless interaction.account.billing_enabled?

    tariff_plan = interaction.account.tariff_plans.find_by(category: interaction.tariff_schedule_category)

    if tariff_plan.blank?
      @error_code = :subscription_disabled
    elsif !tariff_exists?(tariff_plan:, destination: interaction.to.value)
      @error_code = :destination_blocked
    elsif !credit_validator.sufficient_balance?(interaction)
      @error_code = :insufficient_balance
    end

    @error_code.blank?
  end

  private

  def tariff_exists?(...)
    tariff_calculator.calculate(...).present?
  end
end
