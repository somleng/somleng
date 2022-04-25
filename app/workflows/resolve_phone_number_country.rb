class ResolvePhoneNumberCountry < ApplicationWorkflow
  FALLBACK_COUNTRIES = %w[US AU NF FI NO MA FK GB IT RU NZ RE].freeze

  attr_reader :phone_number, :fallback_country

  def initialize(phone_number, fallback_country:)
    @phone_number = phone_number
    @fallback_country = fallback_country
  end

  def call
    return possible_countries.first if possible_countries.one?

    result = possible_countries.find { |country| country == fallback_country }
    result || possible_countries.find { |country| FALLBACK_COUNTRIES.include?(country.alpha2) }
  end

  private

  def possible_countries
    @possible_countries ||= ISO3166::Country.find_all_country_by_country_code(
      Phony.split(phone_number).first
    )
  end
end
