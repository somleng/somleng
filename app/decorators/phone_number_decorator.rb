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
    phone_number_formatter.format(object.number, format: :international)
  end

  def type_formatted
    object.type.text
  end

  def visibility_formatted
    object.visibility.text
  end

  def active_plan
    object.active_plan&.decorated
  end

  def locality
    object.locality&.titleize
  end

  def formatted_location
    return object.country.iso_short_name if object.iso_region_code.blank? && object.locality.blank?

    [ locality, region_name, object.country.alpha2 ].compact.join(", ")
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end

  def object
    __getobj__
  end
end
