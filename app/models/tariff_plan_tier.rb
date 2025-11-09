class TariffPlanTier < ApplicationRecord
  DEFAULT_WEIGHT = 10.0

  belongs_to :tariff_package
  belongs_to :tariff_schedule

  before_create :set_default_weight

  private

  def set_default_weight
    self.weight ||= DEFAULT_WEIGHT
  end
end
