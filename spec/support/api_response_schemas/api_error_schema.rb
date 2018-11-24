module ApiResponseSchema
  ApiErrorSchema = Dry::Validation.Schema do
    required(:errors).filled(:hash?)
    required(:message).filled(:str?)
    optional(:status).maybe(:int?)
  end
end
