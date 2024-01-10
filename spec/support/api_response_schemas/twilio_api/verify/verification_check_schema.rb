module APIResponseSchema
  module TwilioAPI
    module Verify
      VerificationCheckSchema = Dry::Schema.Params do
        required(:sid).filled(:str?)
        required(:service_sid).filled(:str?)
        required(:account_sid).filled(:str?)
        required(:to).filled(:str?, format?: /\A\+/)
        required(:channel).filled(:str?)
        required(:status).filled(:str?)
        required(:date_created).filled(:str?)
        required(:date_updated).filled(:str?)
      end
    end
  end
end
