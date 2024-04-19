class CountryType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    value.is_a?(ISO3166::Country) ? value : ISO3166::Country.new(value)
  end

  def serialize(value)
    return if value.blank?

    value.is_a?(ISO3166::Country) ? value.alpha2 : value
  end
end
