class TariffSchedule < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  has_many :destination_tariffs

  enumerize :category, in: [ :inbound_calls, :inbound_messages, :outbound_calls, :outbound_messages ]
end
