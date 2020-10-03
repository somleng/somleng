module APIResponseSchema
  APIErrorsSchema = Dry::Schema.Params do
    required(:message).filled(:str?)
    required(:code).filled(:int?)
    required(:status).filled(:int?)
    required(:more_info).filled(:str?)
  end
end
