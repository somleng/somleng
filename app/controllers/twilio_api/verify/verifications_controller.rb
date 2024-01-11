module TwilioAPI
  module Verify
    class VerificationsController < VerifyAPIController
      def show
        verification = verifications_scope.find(params[:id])
        respond_with_resource(verification, **serializer_options)
      end

      def create
        validate_request_schema(
          with: VerificationRequestSchema,
          schema_options: {
            account: current_account, verification_service:, verifications_scope:
          },
          status: :ok,
          **serializer_options
        ) do |permitted_params|
          CreateVerification.call(permitted_params)
        end
      end

      def update
        verification = verifications_scope.find(params[:id])

        validate_request_schema(
          with: UpdateVerificationRequestSchema,
          schema_options: { account: current_account, verification: },
          status: :ok,
          **serializer_options
        ) do |permitted_params|
          verification.fire!(permitted_params.fetch(:event))
          verification
        end
      end

      private

      def serializer_options
        { serializer_class: VerificationSerializer }
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
