# https://www.twilio.com/docs/phone-numbers/api/availablephonenumber-resource#fetch-a-specific-country

module APIResponseSchema
  module TwilioAPI
    CountrySchema = Dry::Schema.Params do
      required(:country_code).filled(:str?)
      required(:country).filled(:str?)
      required(:uri).filled(:str?)
      required(:beta).filled(:bool?)
      required(:subresource_uris).hash do
        required(:local).filled(:string, format?: /\/AvailablePhoneNumbers\/[A-Z]{2}\/Local\z/)
        required(:toll_free).filled(:string, format?: /\/AvailablePhoneNumbers\/[A-Z]{2}\/TollFree\z/)
        required(:mobile).filled(:string, format?: /\/AvailablePhoneNumbers\/[A-Z]{2}\/Mobile\z/)
        required(:short_code).filled(:string, format?: /\/AvailablePhoneNumbers\/[A-Z]{2}\/ShortCode\z/)
      end
    end
  end
end
