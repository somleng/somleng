# https://www.twilio.com/docs/phone-numbers/api/availablephonenumber-resource#fetch-a-specific-country

module APIResponseSchema
  module TwilioAPI
    CountrySchema = Dry::Schema.Params do
      required(:country_code).filled(:str?)
      required(:country).filled(:str?)
      required(:uri).filled(:str?)
      required(:beta).filled(:bool?)
      required(:subresource_uris).hash do
        required(:local).filled(:string)
        required(:toll_free).filled(:string)
        required(:mobile).filled(:string)
      end
    end
  end
end
