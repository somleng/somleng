module TwilioAPI
  class AvailablePhoneNumberSerializer < TwilioAPISerializer
    def attributes
      super.merge(
        friendly_name: nil,
        phone_number: nil,
        lata: nil,
        rate_center: nil,
        latitude: nil,
        longitude: nil,
        locality: nil,
        region: nil,
        postal_code: nil,
        iso_country: nil,
        address_requirements: nil,
        beta: nil,
        capabilities: nil
      )
    end

    def phone_number
      number
    end

    def lata; end
    def rate_center; end
    def latitude; end
    def longitude; end
    def locality; end
    def region; end
    def postal_code; end
    def address_requirements
      "none"
    end

    def iso_country
      iso_country_code
    end

    def capabilities
      {
        voice: true,
        SMS: true,
        MMS: false
      }
    end

    def beta
      false
    end
  end
end
