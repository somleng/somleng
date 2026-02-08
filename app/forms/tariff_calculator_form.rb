class TariffCalculatorForm < ApplicationForm
  attribute :tariff_plan
  attribute :destination
  attribute :tariff_calculator, default: -> { TariffCalculator.new }

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffCalculator")
  end

  def result
    @result ||= tariff_calculator.calculate(tariff_plan:, destination:)
  end
end
