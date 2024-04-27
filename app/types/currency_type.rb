class CurrencyType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    value.is_a?(Money::Currency) ? value : Money::Currency.new(value)
  rescue Money::Currency::UnknownCurrency
    nil
  end

  def serialize(value)
    cast(value)&.iso_code
  end
end
