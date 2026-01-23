class TariffPlan < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_many :tiers, class_name: "TariffPlanTier", foreign_key: :plan_id
  has_many :schedules, through: :tiers, class_name: "TariffSchedule"
  has_many :destination_tariffs, through: :tariff_schedules
  has_many :destination_groups, through: :destination_tariffs
  has_many :destination_prefixes, through: :destination_groups, source: :prefixes
  has_many :subscriptions, class_name: "TariffPlanSubscription", foreign_key: :plan_id, dependent: :restrict_with_error
  has_many :accounts, through: :subscriptions

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue
end
