module TwilioAPI
  class VerifyAPIController < TwilioAPIController
    private

    def verify_account_param?
      false
    end

    def respond_with_resource(resource, options = {})
      respond_with(:api, :twilio, :verify, resource, **options)
    end
  end
end
