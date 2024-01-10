module TwilioAPI
  module Verify
    class VerificationServicesController < VerifyAPIController
      def index
        respond_with(scope, serializer_options)
      end

      def show
        verification_service = scope.find(params[:id])
        respond_with_resource(verification_service, serializer_options)
      end

      def create
        validate_request_schema(
          with: VerificationServiceRequestSchema,
          schema_options: { account: current_account },
          **serializer_options
        ) do |permitted_params|
          scope.create!(permitted_params)
        end
      end

      def update
        verification_service = scope.find(params[:id])

        validate_request_schema(
          with: UpdateVerificationServiceRequestSchema,
          schema_options: { account: current_account, verification_service: },
          status: :ok,
          **serializer_options
        ) do |permitted_params|
          verification_service.update!(permitted_params)
          verification_service
        end
      end

      def destroy
        verification_service = scope.find(params[:id])
        verification_service.destroy!
      end

      private

      def scope
        current_account.verification_services
      end

      def serializer_options
        { serializer_class: VerificationServiceSerializer }
      end
    end
  end
end
