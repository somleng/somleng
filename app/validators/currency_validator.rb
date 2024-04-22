class CurrencyValidator < ActiveModel::EachValidator
  VALID_CURRENCIES = ISO3166::Country.all.map { |country| Money::Currency.new(country.currency_code) }.uniq.freeze

  def validate_each(record, attribute, value)
    return if value.in?(VALID_CURRENCIES)

    record.errors.add(attribute, :inclusion)
  end
end
