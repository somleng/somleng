module TwilioAPI
  class MessageDestinationSchemaRules
    attr_reader :sms_gateway_resolver, :error_code, :account_billing_policy, :sms_gateway

    def initialize(**options)
      @sms_gateway_resolver = options.fetch(:sms_gateway_resolver) { SMSGatewayResolver.new }
      @account_billing_policy = options.fetch(:account_billing_policy) { AccountBillingPolicy.new }
    end

    def valid?(account:, destination:)
      @sms_gateway = sms_gateway_resolver.resolve(carrier: account.carrier, destination:)

      if sms_gateway.blank?
        @error_code = :unreachable_carrier
      elsif insufficient_balance?(account:, destination:)
        @error_code = :insufficient_balance
      end

      @error_code.blank?
    end

    private

    def insufficient_balance?(account:, destination:)
      !account_billing_policy.good_standing?(
        account:,
        usage: "1",
        category: Message.new(direction: "outbound").tariff_category,
        destination:
      )
    end
  end
end
