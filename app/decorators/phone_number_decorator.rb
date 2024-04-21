class PhoneNumberDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :PhoneNumber
  end

  def number
    phone_number_formatter.format(object.number, format: :e164)
  end

  def number_formatted
    phone_number_formatter.format(object.number, format: :international)
  end

  def friendly_name
    phone_number_formatter.format(object.number, format: :national)
  end

  def type
    object.type.text
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end

  def object
    __getobj__
  end
end
