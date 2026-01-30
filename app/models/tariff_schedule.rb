class TariffSchedule < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_many :destination_tariffs, foreign_key: :schedule_id
  has_many :destination_groups, through: :destination_tariffs
  has_many :plan_tiers, class_name: "TariffPlanTier", foreign_key: :schedule_id, dependent: :restrict_with_error
  has_many :plans, through: :plan_tiers

  enumerize :category,
    in: [
      :outbound_calls,
      :inbound_calls,
      :outbound_messages,
      :inbound_messages
    ],
    value_class: TariffScheduleCategoryValue
end
