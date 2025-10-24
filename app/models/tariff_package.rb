class TariffPackage < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_many :tariff_plans
  has_many :tariff_schedules, through: :tariff_plans
  has_many :tariff_bundles, through: :tariff_bundle_line_items
  has_many :account_billing_profiles, through: :tariff_bundles
  has_many :accounts, through: :billing_profiles

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue
end
