class IncomingPhoneNumberDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :IncomingPhoneNumber
  end

  delegate :type_formatted, to: :phone_number, allow_nil: true

  def number
    phone_number_formatter.format(object.number, format: :e164)
  end

  def status_color
    active? ? :success : :secondary
  end

  def number_formatted
    phone_number_formatter.format(object.number, format: :international)
  end

  def phone_number
    object.phone_number&.decorated
  end

  def phone_number_plan
    object.phone_number_plan.decorated
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end

  def object
    __getobj__
  end
end
