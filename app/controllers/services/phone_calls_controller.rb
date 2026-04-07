module Services
  class PhoneCallsController < ServicesController
    def update
      phone_call = PhoneCall.find(params[:id])

      validate_request_schema(with: UpdatePhoneCallRequestSchema) do |permitted_params|
        phone_call.update!(permitted_params)
      end
    end

    private

    def respond_with_resource(*)
      head(:no_content)
    end
  end
end
