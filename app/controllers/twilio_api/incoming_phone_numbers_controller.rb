module TwilioAPI
  class IncomingPhoneNumbersController < TwilioAPIController
    def index
      validate_request_schema(
        with: IncomingPhoneNumberFilterRequestSchema,
        schema_options: { account: current_account },
        input_params: request.params,
        **serializer_options
      ) do |permitted_params|
        scope.where(permitted_params)
      end
    end

    def show
      phone_number = scope.find(params[:id])
      respond_with_resource(phone_number, serializer_options)
    end

    def create
      validate_request_schema(
        with: IncomingPhoneNumberRequestSchema,
        schema_options: { account: current_account },
        **serializer_options
      ) do |permitted_params|
        CreatePhoneNumberPlan.call(**permitted_params).incoming_phone_number
      end
    end

    def update
      incoming_phone_number = scope.find(params[:id])

      validate_request_schema(
        with: IncomingPhoneNumberRequestSchema,
        schema_options: { account: current_account, incoming_phone_number: },
        status: :ok,
        **serializer_options
      ) do |permitted_params|
        incoming_phone_number.update!(permitted_params)
        incoming_phone_number
      end
    end

    def destroy
      incoming_phone_number = scope.find(params[:id])
      incoming_phone_number.release!
    end

    private

    def respond_with_resource(resource, options = {})
      super(resource, location: api_twilio_account_incoming_phone_number_path(current_account, resource), **options)
    end

    def scope
      current_account.active_managed_incoming_phone_numbers
    end

    def serializer_options
      { serializer_class: IncomingPhoneNumberSerializer }
    end
  end
end
