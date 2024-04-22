module CSVSerializer
  class PhoneNumberSerializer < ResourceSerializer
    def attributes
      super.merge(
        "account_sid" => nil,
        "number" => nil,
        "type" => nil,
        "enabled" => nil,
        "country" => nil,
      )
    end

    def account_sid
      account_id
    end

    def country
      iso_country_code
    end
  end
end
