class Beneficiary
  attr_reader :phone_number, :fallback_country

  def initialize(phone_number:, fallback_country:)
    @phone_number = PhoneNumberParser.parse(phone_number)
    @fallback_country = fallback_country
  end

  def country
    @country ||= ResolvePhoneNumberCountry.call(phone_number, fallback_country:)
  end
end
