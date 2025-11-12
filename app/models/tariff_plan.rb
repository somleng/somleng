class TariffPlan < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_many :tiers, class_name: "TariffPlanTier"
  has_many :schedules, through: :tiers, class_name: "TariffSchedule", source: :schedule
  has_many :destination_tariffs, through: :tariff_schedules
  has_many :destination_groups, through: :destination_tariffs
  has_many :destination_prefixes, through: :destination_groups, source: :prefixes

  has_many :tariff_packages, through: :tariff_package_plans

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue
end
