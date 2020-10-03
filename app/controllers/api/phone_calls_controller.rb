module API
  class PhoneCallsController < APIController
    def create
      validate_request_schema(with: PhoneCallRequestSchema) do |permitted_params|
        phone_call = current_account.phone_calls.create!(permitted_params)
        OutboundCallJob.perform_later(phone_call)
        phone_call
      end
    end

    def show
      phone_call = current_account.phone_calls.find(params[:id])
      respond_with_resource(phone_call)
    end
  end
end
