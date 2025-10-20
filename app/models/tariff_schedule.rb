class TariffSchedule < ApplicationRecord
  belongs_to :carrier
  has_many :destination_tariffs
end
