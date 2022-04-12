module CarrierAPI
  module V1
    class PhoneNumbersController < CarrierAPIController
      def index
        respond_with_resource(phone_numbers_scope, serializer_options)
      end

      def create
        validate_request_schema(
          with: PhoneNumberRequestSchema, **serializer_options
        ) do |permitted_params|
          phone_numbers_scope.create!(permitted_params)
        end
      end

      def update
        phone_number = find_phone_number

        validate_request_schema(
          with: PhoneNumberRequestSchema,
          schema_options: { resource: phone_number },
          **serializer_options
        ) do |permitted_params|
          phone_number.update!(permitted_params)
          phone_number
        end
      end

      def show
        phone_number = find_phone_number
        respond_with_resource(phone_number, serializer_options)
      end

      def destroy
        phone_number = find_phone_number
        if phone_number.destroy
          respond_with_resource(phone_number)
        else
          respond_with_resource(
            phone_number,
            responder: InvalidRequestSchemaResponder,
            serializer_class: JSONAPIErrorsSerializer
          )
        end
      end

      def release
        phone_number = find_phone_number
        phone_number.release!
        respond_with_resource(phone_number)
      end

      private

      def phone_numbers_scope
        current_carrier.phone_numbers
      end

      def find_phone_number
        phone_numbers_scope.find(params[:id])
      end

      def serializer_options
        { serializer_class: PhoneNumberSerializer }
      end
    end
  end
end
