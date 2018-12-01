module API
  class AbstractPhoneCallSerializer < ResourceSerializer
    INBOUND_CALL_DIRECTION = "inbound".freeze
    OUTBOUND_CALL_DIRECTION = "outbound-api".freeze

    CDR_CALL_DIRECTION_MAPPINGS = {
      "inbound" => INBOUND_CALL_DIRECTION,
      "outbound" => OUTBOUND_CALL_DIRECTION
    }.freeze

    def direction
      return INBOUND_CALL_DIRECTION if inbound_call?
      return CDR_CALL_DIRECTION_MAPPINGS.fetch(cdr.direction) if cdr.present?

      OUTBOUND_CALL_DIRECTION
    end

    private

    def cdr
      serializable.call_data_record
    end

    def inbound_call?
      serializable.incoming_phone_number.present?
    end
  end
end
