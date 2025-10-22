class TariffSchedule < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_many :destination_tariffs

  attribute :category

  enumerize :category,
    in: [
      :inbound_calls,
      :inbound_messages,
      :outbound_calls,
      :outbound_messages
    ],
    value_class: TariffScheduleCategoryValue
end
