class OutboundCallRouter
  attr_reader :destination

  def initialize(destination)
    @destination = Phony.normalize(destination)
  end

  def routing_instructions
    return if destination_gateway.blank?

    {
      "dial_string" => "#{destination_gateway['dial_string_prefix']}#{destination_number}@#{destination_gateway.fetch('host')}"
    }
  end

  private

  def destination_gateway
    @destination_gateway ||= Torasup::PhoneNumber.new(destination).operator.gateway
  end

  def destination_number
    return destination unless destination_gateway["prefix"] == false

    Phony.format(destination, format: :national, spaces: "")
  end
end
