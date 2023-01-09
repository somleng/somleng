module TwilioAPI
  class UpdatePhoneCallRequestSchema < TwilioAPIRequestSchema
    option :phone_call

    params do
      required(:Status).filled(:string, included_in?: PhoneCallStatusEvent::EVENTS.keys)
    end

    def output
      params = super

      {
        status: params.fetch(:Status)
      }
    end
  end
end
