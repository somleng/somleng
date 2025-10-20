class TariffScheduleDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :TariffSchedule
  end
end
