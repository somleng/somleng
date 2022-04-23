class Interaction < ApplicationRecord
  belongs_to :account
  belongs_to :carrier
  belongs_to :interactable, polymorphic: true

  attribute :beneficiary_identifier, SHA256Type.new

  def self.this_month
    where(created_at: Time.current.beginning_of_month..Time.current.end_of_month)
  end

  def beneficiary_country
    ISO3166::Country.new(beneficiary_country_code)
  end
end
