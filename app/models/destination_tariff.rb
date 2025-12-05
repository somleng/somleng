class DestinationTariff < ApplicationRecord
  belongs_to :schedule, class_name: "TariffSchedule"
  belongs_to :destination_group
  belongs_to :tariff, dependent: :destroy, autosave: true
  has_many :plans, through: :schedule
end
