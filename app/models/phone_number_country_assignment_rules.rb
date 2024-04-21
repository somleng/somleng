class PhoneNumberCountryAssignmentRules
  attr_reader :phone_number_parser

  def initialize(phone_number_parser: PhoneNumberParser.new)
    @phone_number_parser = phone_number_parser
  end

  def country_for(number:, preferred_country:, fallback_country:, existing_country: nil)
    return existing_country if preferred_country.blank? && existing_country.present?

    phone_number = phone_number_parser.parse(number)

    if phone_number.e164?
      if preferred_country.present?
        preferred_country if preferred_country.in?(phone_number.possible_countries)
      else
        ResolvePhoneNumberCountry.call(phone_number, fallback_country:)
      end
    else
      preferred_country.present? ? preferred_country : fallback_country
    end
  end
end
