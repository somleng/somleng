module TwilioAPI
  class VerifyAPIController < TwilioAPIController
    private

    def verify_account_param?
      false
    end

    def respond_with_resource(resource, options = {})
      respond_with(:api, :twilio, :verify, resource, **options)
    end

    def verification_service
      @verification_service ||= current_account.verification_services.find(params[:service_id])
    end

    def verifications_scope
      verification_service.verifications.pending
    end
  end
end
