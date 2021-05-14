module API
  class PhoneCallsController < APIController
    def create
      validate_request_schema(with: PhoneCallRequestSchema) do |permitted_params|
        phone_call = phone_calls_scope.create!(permitted_params)
        OutboundCallJob.perform_later(phone_call)
        phone_call
      end
    end

    def update
      phone_call = phone_calls_scope.find(params[:id])

      validate_request_schema(
        with: UpdatePhoneCallRequestSchema, schema_options: { phone_call: phone_call }, status: :ok
      ) do |permitted_params|
        if PhoneCallStatusEvent.new(phone_call).may_transition_to?(permitted_params[:status])
          EndCallJob.perform_later(phone_call)
        end
        phone_call
      end
    end

    def show
      phone_call = phone_calls_scope.find(params[:id])
      respond_with_resource(phone_call)
    end

    private

    def phone_calls_scope
      current_account.phone_calls
    end
  end
end
