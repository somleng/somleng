module TwilioAPI
  class UpdatePhoneCallRequestSchema < ApplicationRequestSchema
    option :phone_call

    params do
      required(:Status).filled(:string, included_in?: PhoneCallStatusEvent::EVENTS)
    end

    def output
      params = super

      {
        status: params.fetch(:Status)
      }
    end
  end
end
