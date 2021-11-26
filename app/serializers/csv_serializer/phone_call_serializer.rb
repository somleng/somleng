module CSVSerializer
  class PhoneCallSerializer < ResourceSerializer
    def attributes
      super.merge(
        "sid" => nil,
        "account_sid" => nil,
        "phone_number_sid" => nil,
        "from" => nil,
        "to" => nil,
        "duration" => nil,
        "direction" => nil,
        "status" => nil
      )
    end
  end
end
