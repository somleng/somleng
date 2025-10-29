class TariffSchedule < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_many :destination_tariffs
  has_many :tariff_plans
  has_many :tariff_packages, through: :tariff_plans

  enumerize :category,
    in: [
      :outbound_messages,
      :inbound_messages,
      :outbound_calls,
      :inbound_calls
    ],
    value_class: TariffScheduleCategoryValue
end
