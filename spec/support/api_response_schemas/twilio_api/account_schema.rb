# https://www.twilio.com/docs/iam/api/account#account-properties

module APIResponseSchema
  module TwilioAPI
    AccountSchema = Dry::Schema.Params do
      required(:status).filled(:string, included_in?: [ "active", "suspended", "closed" ])
      required(:auth_token).filled(:str?)
      required(:friendly_name).filled(:str?)
      required(:owner_account_sid).maybe(:str?)
      required(:uri).filled(:str?)
      required(:sid).filled(:str?)
      required(:type).filled(:string, included_in?: [ "Trial", "Full" ])
      required(:date_updated).filled(:str?)
      required(:date_created).filled(:str?)
      required(:subresource_uris).hash do
        required(:calls).filled(:string)
        required(:messages).filled(:string)
        required(:recordings).filled(:string)
      end
    end
  end
end
