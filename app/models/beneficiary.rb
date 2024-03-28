class Beneficiary
  attr_reader :phone_number, :fallback_country, :phone_number_validator

  def initialize(phone_number:, fallback_country:, **options)
    @phone_number = phone_number
    @fallback_country = fallback_country
    @phone_number_validator = options.fetch(:phone_number_validator) { PhoneNumberValidator.new }
  end

  def valid?
    phone_number_validator.valid?(phone_number)
  end

  def country
    @country ||= ResolvePhoneNumberCountry.call(
      phone_number,
      fallback_country:
    )
  end
end
