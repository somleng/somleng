module TwilioAPI
  class VerifyAPIController < TwilioAPIController
    private

    def verify_account_param?
      false
    end

    def verification_service
      @verification_service ||= current_account.verification_services.find(params[:service_id])
    end

    def verifications_scope
      verification_service.verifications.pending
    end
  end
end
