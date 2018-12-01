module API
  PhoneCallRequestSchema = Dry::Validation.Params(AbstractPhoneCallRequestSchema) do
    required(:To, ApplicationRequestSchema::Types::PhoneNumber).filled(:phone_number?)
    required(:From, ApplicationRequestSchema::Types::PhoneNumber).filled(:str?, format?: phone_number_regex)
    required(:Url, :string).filled(:str?, url?: true)
    optional(:Method, ApplicationRequestSchema::Types::HTTPMethod).filled(:str?, included_in?: http_methods)
    optional(:StatusCallback, :string).filled(:str?, url?: true)
    optional(:StatusCallbackMethod, ApplicationRequestSchema::Types::HTTPMethod).filled(:str?, included_in?: http_methods)
  end
end
