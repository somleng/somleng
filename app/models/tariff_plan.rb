class TariffPlan < ApplicationRecord
  belongs_to :tariff_package
  belongs_to :tariff_schedule
end
