# https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#incomingphonenumber-properties

module APIResponseSchema
  module TwilioAPI
    IncomingPhoneNumberSchema = Dry::Schema.Params do
      required(:sid).filled(:str?)
      required(:account_sid).filled(:str?)
      required(:api_version).filled(:str?, eql?: "2010-04-01")
      required(:date_created).filled(:str?)
      required(:date_updated).filled(:str?)
      required(:address_requirements).filled(:str?, included_in?: [ "none", "any", "local", "foreign" ])
      required(:address_sid).maybe(:str?)
      required(:beta).filled(:bool?)
      required(:capabilities).hash do
        required(:voice).filled(:bool)
        required(:sms).filled(:bool)
        required(:mms).filled(:bool)
        required(:fax).filled(:bool)
      end
      required(:emergency_status).filled(:str?, included_in?: [ "Active", "Inactive" ])
      required(:emergency_address_sid).maybe(:str?)
      required(:emergency_address_status).filled(
        :str?,
        included_in?: [
          "registered",
          "unregistered",
          "pending-registration",
          "registration-failure",
          "pending-unregistration",
          "unregistration-failure"
        ]
      )
      required(:friendly_name).filled(:str?)
      required(:identity_sid).maybe(:str?)
      required(:origin).filled(:str?, included_in?: [ "somleng", "hosted" ])
      required(:phone_number).filled(:str?)
      required(:sms_application_sid).maybe(:str?)
      required(:sms_fallback_method).filled(:str?, included_in?: [ "POST", "GET" ])
      required(:sms_fallback_url).maybe(:str?)
      required(:sms_method).filled(:str?, included_in?: [ "POST", "GET" ])
      required(:sms_url).maybe(:str?)
      required(:status_callback).maybe(:str?)
      required(:status_callback_method).filled(:str?, included_in?: [ "POST", "GET" ])
      required(:trunk_sid).maybe(:str?)
      required(:uri).filled(:str?)
      required(:voice_application_sid).maybe(:str?)
      required(:voice_caller_id_lookup).filled(:bool?)
      required(:voice_fallback_method).filled(:str?, included_in?: [ "POST", "GET" ])
      required(:voice_fallback_url).maybe(:str?)
      required(:voice_method).filled(:str?, included_in?: [ "POST", "GET" ])
      required(:voice_url).maybe(:str?)
      required(:bundle_sid).maybe(:str?)
      required(:voice_receive_mode).filled(:str?, included_in?: [ "voice", "fax" ])
      required(:status).filled(:str?, eql?: "in-use")
    end
  end
end
