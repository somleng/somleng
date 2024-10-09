module CSVSerializer
  class PhoneNumberSerializer < ResourceSerializer
    def attributes
      super.merge(
        "number" => nil,
        "type" => nil,
        "visibility" => nil,
        "country" => nil,
        "price" => nil,
        "currency" => nil,
        "region" => nil,
        "locality" => nil,
        "lata" => nil,
        "rate_center" => nil
      )
    end

    def country
      iso_country_code
    end

    def region
      iso_region_code&.upcase
    end
  end
end
