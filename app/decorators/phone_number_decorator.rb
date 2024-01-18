class PhoneNumberDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :Message
  end

  def number_formatted
    phone_number_formatter.format(object.number, format: :international)
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end

  def object
    __getobj__
  end
end
