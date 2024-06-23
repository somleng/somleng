module Services
  class OutboundPhoneCallSerializer < ResourceSerializer
    def serializable_hash(options = nil)
      serializable_is_collection? ? hash_for_collection(options) : super
    end
    alias to_hash serializable_hash

    def attributes
      super.merge(
        "sid" => nil,
        "parent_call_sid" => nil,
        "to" => nil,
        "dial_string_prefix" => nil,
        "plus_prefix" => nil,
        "national_dialing" => nil,
        "host" => nil,
        "username" => nil,
        "symmetric_latching" => nil
      )
    end

    def parent_call_sid
      object.parent_call_id
    end

    def dial_string_prefix
      object.sip_trunk.outbound_dial_string_prefix
    end

    def plus_prefix
      object.sip_trunk.outbound_plus_prefix?
    end

    def national_dialing
      object.sip_trunk.outbound_national_dialing?
    end

    def host
      object.sip_trunk.outbound_host
    end

    def username
      object.sip_trunk.username
    end

    def symmetric_latching
      object.sip_trunk.outbound_symmetric_latching_supported?
    end

    private

    def hash_for_collection(options)
      data = object.map do |record|
        self.class.new(record.decorated, serializer_options).serializable_hash(options)
      end

      { collection_name => data }
    end

    def serializable_is_collection?
      object.respond_to?(:each) && object.respond_to?(:size)
    end

    def collection_name
      :phone_calls
    end
  end
end
