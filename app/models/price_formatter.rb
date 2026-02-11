class PriceFormatter
  attr_reader :formatter

  def initialize(formatter: ActiveSupport::NumberHelper)
    @formatter = formatter
  end

  def format(value, with_currency: false)
    return if value.blank?

    with_currency ? format_with_currency(value) : format_without_currency(value)
  end

  private

  def format_with_currency(value)
    formatter.number_to_currency(
      value,
      unit: value.currency.symbol,
      precision: 5
    )
  end

  def format_without_currency(value)
    return if value.blank?

    "%0.5f" % value.to_f
  end
end
