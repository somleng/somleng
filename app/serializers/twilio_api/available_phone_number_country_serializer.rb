module TwilioAPI
  class AvailablePhoneNumberCountrySerializer < TwilioAPISerializer
    COLLECTION_NAME = :countries

    def attributes
      super.merge(
        country_code: nil,
        country: nil,
        uri: nil,
        beta: nil,
        subresource_uris: nil
      )
    end

    def country_code
      iso_country_code
    end

    def country
      object.country.iso_short_name
    end

    def beta
      false
    end

    def uri
      url_helpers.api_twilio_account_available_phone_number_country_path(account, country_code, format: :json)
    end

    def subresource_uris
      PhoneNumber.type.values.each_with_object({}) do |type, result|
        result[type] = url_helpers.api_twilio_account_available_phone_numbers_path(account, country_code, type.to_s.camelize, format: :json)
      end
    end

    private

    def pagination_serializer
      NoPaginationSerializer.new(serializer_options.fetch(:pagination_info))
    end

    def account
      serializer_options.fetch(:account)
    end

    def collection_name
      COLLECTION_NAME
    end
  end
end
