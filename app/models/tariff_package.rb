class TariffPackage < ApplicationRecord
  belongs_to :carrier

  has_many :account_billing_profiles
  has_many :accounts, through: :account_billing_profiles
  has_many :line_items, class_name: "TariffPackagePlan", inverse_of: :tariff_package, autosave: true
  has_many :tariff_plans, through: :line_items
end
