module TwilioAPI
  class PhoneCallsController < TwilioAPIController
    def index
      respond_with(scope, serializer_options)
    end

    def create
      validate_request_schema(
        with: PhoneCallRequestSchema,
        schema_options: { account: current_account },
        **serializer_options
      ) do |permitted_params|
        phone_call = scope.create!(permitted_params)
        ScheduleOutboundCall.call(phone_call)
        phone_call
      end
    end

    def update
      phone_call = scope.find(params[:id])

      validate_request_schema(
        with: UpdatePhoneCallRequestSchema,
        schema_options: { account: current_account, phone_call: },
        status: :ok,
        **serializer_options
      ) do |permitted_params|
        end_call(phone_call, permitted_params)
        phone_call
      end
    end

    def show
      phone_call = scope.find(params[:id])
      respond_with_resource(phone_call, serializer_options)
    end

    private

    def scope
      current_account.phone_calls
    end

    def end_call(phone_call, params)
      return unless PhoneCallStatusEvent.new(phone_call).may_transition_to?(params[:status])

      phone_call.was_initiated? ? EndCallJob.perform_later(phone_call) : phone_call.cancel!
    end

    def serializer_options
      { serializer_class: PhoneCallSerializer }
    end
  end
end
