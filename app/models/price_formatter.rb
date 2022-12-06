class PriceFormatter
  attr_reader :formatter

  def initialize(formatter: ActiveSupport::NumberHelper)
    @formatter = formatter
  end

  def format(value, currency)
    return if value.blank?

    formatter.number_to_currency(
      value,
      unit: Money::Currency.new(currency).symbol,
      precision: 6
    )
  end
end
