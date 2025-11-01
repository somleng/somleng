class TariffPackage < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_many :tariff_plans
  has_many :tariff_schedules, through: :tariff_plans
  has_many :destination_tariffs, through: :tariff_schedules
  has_many :destination_groups, through: :destination_tariffs
  has_many :destination_prefixes, through: :destination_groups, source: :prefixes

  has_many :tariff_bundles, through: :tariff_bundle_line_items

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue
end
