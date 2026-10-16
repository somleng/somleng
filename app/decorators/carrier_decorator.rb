class CarrierDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: "Carrier"
  end

  def api_allowed_ip_addresses
    comma_separated_list_formatter.format(object.api_allowed_ip_addresses.pluck(:ip_address).map(&:to_s))
  end

  private

  def comma_separated_list_formatter
    @comma_separated_list_formatter ||= CommaSeparatedListFormatter.new
  end

  def object
    __getobj__
  end
end
