class DestinationTariffDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :DestinationTariff
  end

  def tariff_schedule_name
    decorated_tariff_schedule.name
  end

  def destination_group_name
    decorated_destination_group.name
  end

  def tariff_name
    decorated_tariff.name
  end

  def tariff_rate
    decorated_tariff.rate
  end

  private

  def decorated_tariff_schedule
    @decorated_tariff_schedule = TariffScheduleDecorator.new(tariff_schedule)
  end

  def decorated_tariff
    @decorated_tariff ||= TariffDecorator.new(tariff)
  end

  def decorated_destination_group
    @decorated_destination_group ||= DestinationGroupDecorator.new(destination_group)
  end
end
