class DestinationTariff < ApplicationRecord
  belongs_to :tariff_schedule
  belongs_to :destination_group
  belongs_to :tariff

  delegate :category, to: :tariff
end
