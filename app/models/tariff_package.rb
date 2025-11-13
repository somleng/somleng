class TariffPackage < ApplicationRecord
  belongs_to :carrier

  has_many :account_billing_profiles
  has_many :accounts, through: :account_billing_profiles
  has_many :package_plans, class_name: "TariffPackagePlan", foreign_key: :package_id
  has_many :plans, through: :package_plans, class_name: "TariffPlan"
end
