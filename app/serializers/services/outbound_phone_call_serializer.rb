module Services
  class OutboundPhoneCallSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "destination" => nil,
        "dial_string_prefix" => nil,
        "plus_prefix" => nil,
        "national_dialing" => nil,
        "host" => nil,
        "username" => nil,
        "symmetric_latching" => nil
      )
    end
  end
end
