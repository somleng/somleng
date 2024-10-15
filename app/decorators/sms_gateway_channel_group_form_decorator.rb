class SMSGatewayChannelGroupFormDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :SMSGatewayChannelGroupForm
  end

  def route_prefixes_formatted
    comma_separated_list_formatter.format(object.route_prefixes)
  end

  private

  def comma_separated_list_formatter
    @comma_separated_list_formatter ||= CommaSeparatedListFormatter.new
  end

  def object
    __getobj__
  end
end
