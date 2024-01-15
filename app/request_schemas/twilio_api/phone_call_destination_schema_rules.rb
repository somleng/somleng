module TwilioAPI
  class PhoneCallDestinationSchemaRules
    attr_accessor :account, :destination
    attr_writer :destination_rules
    attr_reader :error_code

    delegate :sip_trunk, to: :destination_rules

    def initialize(options = {})
      @account = options[:account]
      @destination = options[:destination]
      @destination_rules = options[:destination_rules]
    end

    def destination_rules
      @destination_rules ||= DestinationRules.new(
        account:,
        destination:
      )
    end

    def valid?
      if !destination_rules.calling_code_allowed?
        @error_code = :call_blocked_by_blocked_list
      elsif destination_rules.sip_trunk.blank?
        @error_code = :calling_number_unsupported_or_invalid
      end

      error_code.blank?
    end
  end
end
