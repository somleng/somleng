class PhoneNumberCountryAssignmentRules
  attr_reader :phone_number_parser

  def initialize(phone_number_parser: PhoneNumberParser.new)
    @phone_number_parser = phone_number_parser
  end

  def assign_country(number:, preferred_country:, fallback_country:, existing_country: nil)
    return existing_country if preferred_country.blank? && existing_country.present?
    return if number.blank?

    phone_number = phone_number_parser.parse(number)
    return fallback_country if preferred_country.blank? && phone_number.e164?
    return ResolvePhoneNumberCountry.call(phone_number, fallback_country:) if preferred_country.blank? && phone_number.e164?

    preferred_country if !phone_number.e164? || preferred_country.in?(phone_number.possible_countries)
  end
end
