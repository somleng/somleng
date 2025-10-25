class TariffBundle < ApplicationRecord
  belongs_to :carrier

  has_many :account_billing_profiles
  has_many :accounts, through: :account_billing_profiles
  has_many :line_items, class_name: "TariffBundleLineItem", inverse_of: :tariff_bundle, autosave: true
  has_many :tariff_packages, through: :line_items
end
