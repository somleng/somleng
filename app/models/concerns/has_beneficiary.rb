module HasBeneficiary
  extend ActiveSupport::Concern

  included do
    attribute :phone_number_validator, default: -> { PhoneNumberValidator.new }
    attribute :beneficiary_fingerprint, SHA256Type.new
    before_create :set_beneficiary_data
  end

  private

  def set_beneficiary_data
    return if beneficiary.blank?

    self.beneficiary_fingerprint = beneficiary
    self.beneficiary_country_code = ResolvePhoneNumberCountry.call(
      beneficiary,
      fallback_country: carrier.country
    ).alpha2
  end

  def beneficiary
    @beneficiary ||= begin
      beneficiary_phone_number = outbound? ? to : from
      beneficiary_phone_number if phone_number_validator.valid?(beneficiary_phone_number)
    end
  end
end
