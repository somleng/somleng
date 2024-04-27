class PhoneNumberCountryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?
    return if record.number.blank?
    return if ISO3166::Country.new(value).in?(record.number.possible_countries)

    record.errors.add(attribute, :invalid)
  end
end
