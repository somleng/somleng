class Carrier < ApplicationRecord
  has_many :accounts
  has_many :account_memberships, through: :accounts
  has_many :users
  has_many :outbound_sip_trunks

  has_one_attached :logo

  def country
    ISO3166::Country.new(country_code)
  end
end
