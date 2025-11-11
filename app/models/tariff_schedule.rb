class TariffSchedule < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_many :destination_tariffs
  has_many :plan_tiers, class_name: "TariffPlanTier"
  has_many :packages, through: :plan_tiers

  enumerize :category,
    in: [
      :outbound_messages,
      :inbound_messages,
      :outbound_calls,
      :inbound_calls
    ],
    value_class: TariffScheduleCategoryValue
end
