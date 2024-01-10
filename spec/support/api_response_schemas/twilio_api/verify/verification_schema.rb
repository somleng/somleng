module APIResponseSchema
  module TwilioAPI
    module Verify
      VerificationSchema = Dry::Schema.Params do
        required(:sid).filled(:str?)
        required(:service_sid).filled(:str?)
        required(:account_sid).filled(:str?)
        required(:to).filled(:str?)
        required(:channel).filled(:str?)
        required(:status).filled(:str?)
        required(:date_created).filled(:str?)
        required(:date_updated).filled(:str?)
        required(:url).filled(:str?)

        required(:send_code_attempts).value(:array).each do
          schema do
            required(:attempt_sid).filled(:str?)
            required(:channel).filled(:str?)
            required(:time).filled(:date?)
          end
        end
      end
    end
  end
end
