module APIResponseSchema
  module TwilioAPI
    APIErrorsSchema = Dry::Schema.Params do
      required(:message).filled(:str?)
      required(:code).filled(:str?)
      required(:status).filled(:int?)
      required(:more_info).filled(:str?)
    end
  end
end
