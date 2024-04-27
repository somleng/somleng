module TwilioAPI
  class IncomingPhoneNumberFilterRequestSchema < TwilioAPIRequestSchema
    def self.error_serializer_class
      TwilioAPI::BadRequestErrorSerializer
    end

    params do
      optional(:PhoneNumber).filled(ApplicationRequestSchema::Types::Number)
    end

    def output
      params = super

      {
        number: params[:PhoneNumber]
      }.compact
    end
  end
end
