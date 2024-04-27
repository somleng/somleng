module CSVSerializer
  class PhoneNumberSerializer < ResourceSerializer
    def attributes
      super.merge(
        "number" => nil,
        "type" => nil,
        "visibility" => nil,
        "country" => nil,
        "price" => nil,
        "currency" => nil
      )
    end

    def country
      iso_country_code
    end
  end
end
