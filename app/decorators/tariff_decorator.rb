class TariffDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :Tariff
  end

  def message_rate
    return if message_tariff.blank?

    display_rate(object.message_tariff.rate)
  end

  def per_minute_rate
    return if call_tariff.blank?

    rate = display_rate(object.call_tariff.per_minute_rate)
    return rate if call_tariff.per_minute_rate.zero?

    [ rate, "per minute" ].join(" ")
  end

  def connection_fee
    return if call_tariff.blank?

    display_rate(object.call_tariff.connection_fee)
  end

  def rate
    if message?
      message_rate
    elsif call?
      per_minute_rate
    end
  end

  private

  def display_rate(rate)
    return if rate.blank?

    rate.format
  end

  def object
    __getobj__
  end
end
