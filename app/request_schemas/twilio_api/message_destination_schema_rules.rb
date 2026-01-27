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
      elsif !account_billing_policy_valid?(account:, destination:)
        @error_code = account_billing_policy.error_code
      end

      @error_code.blank?
    end

    private

    def account_billing_policy_valid?(account:, destination:)
      !account_billing_policy.valid?(
        account:,
        usage: "1",
        category: Message.new(direction: :outbound_api).tariff_category,
        destination:
      )
    end
  end
end
