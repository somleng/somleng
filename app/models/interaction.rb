class Interaction < ApplicationRecord
  belongs_to :account
  belongs_to :carrier
  belongs_to :interactable, polymorphic: true

  attribute :beneficiary_fingerprint, SHA256Type.new

  def beneficiary_country
    ISO3166::Country.new(beneficiary_country_code)
  end
end
