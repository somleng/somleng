class Interaction < ApplicationRecord
  extend Enumerize
  enumerize :interactable_type, in: %w[Message PhoneCall]

  belongs_to :account
  belongs_to :carrier
  belongs_to :phone_call, optional: true
  belongs_to :message, optional: true

  attribute :beneficiary_fingerprint, SHA256Type.new

  def beneficiary_country
    ISO3166::Country.new(beneficiary_country_code)
  end
end
