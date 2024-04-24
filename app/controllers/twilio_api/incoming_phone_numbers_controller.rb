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
        CreatePhoneNumberPlan.call(**permitted_params).phone_number
      end
    end

    private

    def respond_with_resource(resource, options = {})
      super(resource, location: api_twilio_account_incoming_phone_number_path(current_account, resource), **options)
    end

    def scope
      current_account.phone_numbers
    end

    def serializer_options
      { serializer_class: IncomingPhoneNumberSerializer }
    end
  end
end
