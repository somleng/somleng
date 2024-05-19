class CountrySubdivisionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    country = ISO3166::Country.new(options.fetch(:country_code).call(record))
    return record.errors.add(options.fetch(:country_attribute, :country), :blank) if country.blank?

    return if country.subdivisions.keys.include?(value.upcase)

    record.errors.add(attribute, :invalid)
  end
end
