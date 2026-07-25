module SchemaRules
  class PhoneCallDestinationSchemaRules
    attr_reader :error_code, :account_billing_policy, :destination_rules, :sip_trunk_resolver, :sip_trunk

    def initialize(**options)
      @account_billing_policy = options.fetch(:account_billing_policy) { AccountBillingPolicy.new }
      @destination_rules = options.fetch(:destination_rules) { DestinationRules.new }
      @sip_trunk_resolver = options.fetch(:sip_trunk_resolver) { OutboundSIPTrunkResolver.new }
    end

    def valid?(account:, destination:)
      if !destination_rules.valid?(account:, destination:)
        @error_code = @destination_rules.error_code
      elsif !(@sip_trunk = sip_trunk_resolver.execute(account:, destination:))
        @error_code = :calling_number_unsupported_or_invalid
      elsif account.billing_enabled? && sip_trunk.region.alias != "hydrogen"
        @error_code = :region_not_supported
      elsif !account_billing_policy_valid?(account:, destination:)
        @error_code = account_billing_policy.error_code
      end

      error_code.blank?
    end

    private

    def account_billing_policy_valid?(account:, destination:)
      account_billing_policy.valid?(
        interaction: PhoneCall.new(account:, direction: :outbound_api, to: destination)
      )
    end
  end
end
