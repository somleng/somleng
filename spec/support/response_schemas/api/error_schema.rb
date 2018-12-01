module ResponseSchema
  module API
    ErrorSchema = Dry::Validation.Schema do
      required(:errors).filled(:hash?)
      required(:message).filled(:str?)
      optional(:status).maybe(:int?)
    end
  end
end
