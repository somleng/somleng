# https://www.twilio.com/docs/phone-numbers/api/availablephonenumberlocal-resource#availablephonenumberlocal-properties

module APIResponseSchema
  module TwilioAPI
    AvailablePhoneNumberSchema = Dry::Schema.Params do
      required(:friendly_name).filled(:str?)
      required(:phone_number).filled(:str?)
      required(:lata).maybe(:str?)
      required(:rate_center).maybe(:str?)
      required(:latitude).maybe(:str?)
      required(:longitude).maybe(:str?)
      required(:locality).maybe(:str?)
      required(:region).maybe(:str?)
      required(:postal_code).maybe(:str?)
      required(:iso_country).filled(:str?, included_in?: ISO3166::Country.all.map(&:alpha2))
      required(:address_requirements).filled(:str?, included_in?: [ "none", "any", "local", "foreign" ])
      required(:beta).filled(:bool?)
      required(:capabilities).hash do
        required(:voice).filled(:bool)
        required(:SMS).filled(:bool)
        required(:MMS).filled(:bool)
      end
    end
  end
end
