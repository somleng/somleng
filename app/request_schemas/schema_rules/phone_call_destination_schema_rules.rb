module SchemaRules
  class PhoneCallDestinationSchemaRules
    attr_reader :error_code, :account_billing_policy

    def initialize(**options)
      @account_billing_policy = options.fetch(:account_billing_policy) { AccountBillingPolicy.new }
    end

    def valid?(account:, destination:)
      @destination_rules = DestinationRules.new(account:, destination:)

      if !@destination_rules.calling_code_allowed?
        @error_code = :call_blocked_by_blocked_list
      elsif @destination_rules.sip_trunk.blank?
        @error_code = :calling_number_unsupported_or_invalid
      elsif !account_billing_policy_valid?(account:, destination:)
        @error_code = account_billing_policy.error_code
      end

      error_code.blank?
    end

    def sip_trunk
      @destination_rules.sip_trunk
    end

    private

    def account_billing_policy_valid?(account:, destination:)
      account_billing_policy.valid?(
        interaction: PhoneCall.new(account:, direction: :outbound_api, to: destination)
      )
    end
  end
end
