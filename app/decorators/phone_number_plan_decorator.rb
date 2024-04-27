class PhoneNumberPlanDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :PhoneNumberPlan
  end

  def number_formatted
    phone_number_formatter.format(object.number, format: :international)
  end

  def status_color
    active? ? :success : :secondary
  end

  def phone_number
    object.phone_number&.decorated
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end

  def object
    __getobj__
  end
end
