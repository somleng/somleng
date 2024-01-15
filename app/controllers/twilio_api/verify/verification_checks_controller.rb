module TwilioAPI
  module Verify
    class VerificationChecksController < VerifyAPIController
      def create
        validate_request_schema(
          with: VerificationCheckRequestSchema,
          schema_options: {
            account: current_account,
            verification_service:,
            verifications_scope:
          },
          status: :ok,
          **serializer_options
        ) do |permitted_params|
          CheckVerificationCode.call(**permitted_params)
        end
      end

      private

      def serializer_options
        { serializer_class: VerificationCheckSerializer }
      end

      def respond_with_resource(resource, options = {})
        respond_with(
          resource,
          location: api_twilio_verify_service_verification_path(verification_service, resource),
          **options
        )
      end
    end
  end
end
