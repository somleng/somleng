class TariffDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :Tariff
  end

  def category
    object.category.text
  end

  def rate
    if message?
      display_rate(object.rate)
    elsif call?
      [ display_rate(object.rate), "/ min" ].join(" ")
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
