class ResolvePhoneNumberCountry < ApplicationWorkflow
  FALLBACK_COUNTRIES = %w[US AU NF FI NO MA FK GB IT RU NZ RE].freeze

  attr_reader :phone_number, :fallback_country

  def initialize(phone_number, fallback_country:)
    @phone_number = phone_number
    @fallback_country = fallback_country
  end

  def call
    return phone_number.country if phone_number.country.present?

    result = phone_number.possible_countries.find { |country| country == fallback_country }
    result ||= phone_number.possible_countries.find { |country| country.alpha2.in?(FALLBACK_COUNTRIES) }
    result
  end
end
