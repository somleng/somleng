module TwilioAPI
  class AvailablePhoneNumbersController < TwilioAPIController
    def index
      validate_request_schema(
        with: AvailablePhoneNumberFilterRequestSchema,
        schema_options: { account: current_account },
        input_params: request.params,
        **serializer_options
      ) do |permitted_params|
        scope.where(permitted_params)
      end
    end

    private

    def scope
      current_account.carrier.phone_numbers.available
    end

    def serializer_options
      { serializer_class: AvailablePhoneNumberSerializer }
    end
  end
end
