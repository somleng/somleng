module SchemaRules
  class PhoneCallDestinationSchemaRules
    attr_reader :error_code

    def valid?(account:, destination:)
      @destination_rules = DestinationRules.new(account:, destination:)

      if !@destination_rules.calling_code_allowed?
        @error_code = :call_blocked_by_blocked_list
      elsif @destination_rules.sip_trunk.blank?
        @error_code = :calling_number_unsupported_or_invalid
      end

      error_code.blank?
    end

    def sip_trunk
      @destination_rules.sip_trunk
    end
  end
end
