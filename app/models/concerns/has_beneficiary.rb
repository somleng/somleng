module HasBeneficiary
  extend ActiveSupport::Concern

  included do
    attribute :beneficiary_fingerprint, SHA256Type.new
    before_create :set_beneficiary_data
  end

  private

  def set_beneficiary_data
    self.beneficiary_fingerprint = beneficiary
    self.beneficiary_country_code = ResolvePhoneNumberCountry.call(
      beneficiary,
      fallback_country: carrier.country
    ).alpha2
  end

  def beneficiary
    outbound? ? to : from
  end
end
