module TwilioAPI
  module Verify
    class ServicesController < VerifyAPIController
      def index
        respond_with(scope, serializer_options)
      end

      def show
        service = scope.find(params[:id])
        respond_with_resource(service, **serializer_options)
      end

      def create
        validate_request_schema(
          with: ServiceRequestSchema,
          schema_options: { account: current_account },
          **serializer_options
        ) do |permitted_params|
          scope.create!(permitted_params)
        end
      end

      def update
        service = scope.find(params[:id])

        validate_request_schema(
          with: UpdateServiceRequestSchema,
          schema_options: { account: current_account, service: },
          status: :ok,
          **serializer_options
        ) do |permitted_params|
          service.update!(permitted_params)
          service
        end
      end

      def destroy
        service = scope.find(params[:id])
        service.destroy!
      end

      private

      def scope
        current_account.verification_services
      end

      def serializer_options
        { serializer_class: ServiceSerializer }
      end

      def respond_with_resource(resource, options = {})
        respond_with(resource, location: api_twilio_verify_service_path(resource), **options)
      end
    end
  end
end
