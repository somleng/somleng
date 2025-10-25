class TariffScheduleDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :TariffSchedule
  end

  def category
    object.category.text
  end

  def name
    "#{category} (#{object.name})"
  end

  private

  def object
    __getobj__
  end
end
