class PhoneNumberPlanDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :PhoneNumberPlan
  end

  def name
    amount.format
  end

  def number_formatted
    phone_number_formatter.format(object.number, format: :international)
  end

  def status_color
    active? ? :success : :danger
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end

  def object
    __getobj__
  end
end
