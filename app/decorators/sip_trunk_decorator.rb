class SIPTrunkDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :SIPTrunk
  end

  def default_sender_formatted
    phone_number_formatter.format(object.default_sender, format: :international)
  end

  def inbound_source_ips_formatted
    comma_separated_list_formatter.format(object.inbound_source_ips)
  end

  def outbound_route_prefixes_formatted
    comma_separated_list_formatter.format(object.outbound_route_prefixes)
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end

  def comma_separated_list_formatter
    @comma_separated_list_formatter ||= CommaSeparatedListFormatter.new
  end

  def object
    __getobj__
  end
end
