module Services
  class OutboundPhoneCallSerializer < ResourceSerializer
    def serializable_hash(options = nil)
      serializable_is_collection? ? hash_for_collection(options) : super
    end
    alias to_hash serializable_hash

    def attributes
      super.merge(
        "sid" => nil,
        "account_sid" => nil,
        "carrier_sid" => nil,
        "parent_call_sid" => nil,
        "from" => nil,
        "direction" => nil,
        "call_direction" => nil,
        "routing_parameters" => nil,
        "billing_parameters" => nil,
        "address" => nil
      )
    end

    def sid
      object.id
    end

    def parent_call_sid
      object.parent_call_id
    end

    def account_sid
      object.account_id
    end

    def carrier_sid
      object.carrier_id
    end

    def address
      # TODO: Remove after deployed

      nil
    end

    def routing_parameters
      RoutingParameters.new(phone_call).to_h
    end

    def billing_parameters
      BillingParameters.new(phone_call).to_h
    end

    def call_direction
      :outbound
    end

    private

    def phone_call
      object.phone_call
    end

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
