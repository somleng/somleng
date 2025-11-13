class TariffDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :Tariff
  end

  def rate
    [ display_rate(object.rate), rate_unit ].compact.join(" ")
  end

  def rate_unit(with_currency: false)
    [ (object.currency.symbol if with_currency), ("/ min" if call?) ].compact.join(" ").presence
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
