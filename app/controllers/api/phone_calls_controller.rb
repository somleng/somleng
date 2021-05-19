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
        end_call(phone_call, permitted_params)
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

    def end_call(phone_call, params)
      return unless PhoneCallStatusEvent.new(phone_call).may_transition_to?(params[:status])

      phone_call.queued? ? phone_call.cancel! : EndCallJob.perform_later(phone_call)
    end
  end
end
