class TariffPlanDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :TariffPlan
  end

  def tariff_package_name
    decorated_tariff_package.name
  end

  def tariff_schedule_name
    decorated_tariff_schedule.name
  end

  private

  def decorated_tariff_package
    @decorated_tariff_package = TariffPackageDecorator.new(tariff_package)
  end

  def decorated_tariff_schedule
    @decorated_tariff_schedule = TariffScheduleDecorator.new(tariff_schedule)
  end
end
