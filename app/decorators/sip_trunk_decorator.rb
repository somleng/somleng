class SIPTrunkDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :SIPTrunk
  end

  def default_sender_formatted
    phone_number_formatter.format(object.default_sender, format: :international)
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end

  def object
    __getobj__
  end
end
