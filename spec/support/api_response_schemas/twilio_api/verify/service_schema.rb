module APIResponseSchema
  module TwilioAPI
    module Verify
      ServiceSchema = Dry::Schema.Params do
        required(:sid).filled(:str?)
        required(:account_sid).filled(:str?)
        required(:friendly_name).filled(:str?)
        required(:code_length).filled(:int?)
        required(:date_created).filled(:str?)
        required(:date_updated).filled(:str?)
        required(:url).filled(:str?)
      end
    end
  end
end
