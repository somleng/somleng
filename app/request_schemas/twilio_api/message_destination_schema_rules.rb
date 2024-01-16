module TwilioAPI
  class MessageDestinationSchemaRules
    attr_accessor :carrier, :destination
    attr_reader :sms_gateway_resolver, :error_code

    def initialize(options = {})
      @carrier = options[:carrier]
      @destination = options[:destination]
      @sms_gateway_resolver = options.fetch(:sms_gateway_resolver) { SMSGatewayResolver.new }
    end

    def valid?
      @error_code = :unreachable_carrier if sms_gateway.blank?

      @error_code.blank?
    end

    def sms_gateway
      @sms_gateway ||= sms_gateway_resolver.resolve(
        carrier:,
        destination:
      )
    end
  end
end
