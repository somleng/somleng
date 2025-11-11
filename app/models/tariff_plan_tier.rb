class TariffPlanTier < ApplicationRecord
  DEFAULT_WEIGHT = 10.0

  belongs_to :plan, class_name: "TariffPlan", foreign_key: :tariff_plan_id
  belongs_to :schedule, class_name: "TariffSchedule", foreign_key: :tariff_schedule_id

  before_create :set_default_weight

  private

  def set_default_weight
    self.weight ||= DEFAULT_WEIGHT
  end
end
