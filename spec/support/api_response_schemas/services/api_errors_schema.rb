module APIResponseSchema
  module Services
    APIErrorsSchema = Dry::Schema.Params do
      required(:message).filled(:str?)
    end
  end
end
