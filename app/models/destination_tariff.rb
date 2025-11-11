class DestinationTariff < ApplicationRecord
  belongs_to :tariff_schedule
  belongs_to :destination_group
  belongs_to :tariff, dependent: :destroy
  has_many :tariff_plans, through: :tariff_schedule, source: :plans
end
