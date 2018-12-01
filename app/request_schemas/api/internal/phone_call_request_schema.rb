module API
  module Internal
    PhoneCallRequestSchema = Dry::Validation.Params(AbstractPhoneCallRequestSchema) do
      required(:To, ApplicationRequestSchema::Types::PhoneNumber).filled(:str?, format?: phone_number_regex)
      required(:From, ApplicationRequestSchema::Types::PhoneNumber).filled(:phone_number?)
      required(:ExternalSid, :string).filled(:str?)
      required(:Variables, :hash).filled(:hash?)
    end
  end
end
