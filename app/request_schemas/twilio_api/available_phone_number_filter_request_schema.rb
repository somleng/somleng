module TwilioAPI
  class AvailablePhoneNumberFilterRequestSchema < TwilioAPIRequestSchema
    def self.error_serializer_class
      TwilioAPI::BadRequestErrorSerializer
    end

    params do
      required(:type).value(:str?, included_in?: PhoneNumber.type.values.map(&:camelize))
      required(:available_phone_number_country_id).value(:str?, included_in?: ISO3166::Country.all.map(&:alpha2))
    end

    def output
      params = super

      {
        type: params.fetch(:type).underscore,
        iso_country_code: params.fetch(:available_phone_number_country_id)
      }
    end
  end
end
