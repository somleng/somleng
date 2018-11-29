module API
  class PhoneCallsController < BaseController
    def create
      schema_validation_result = PhoneCallRequestSchema.schema.call(request.params)
      if schema_validation_result.success?
        phone_call = CreatePhoneCall.call(
          attributes: schema_validation_result.output,
          account: current_account
        )
        respond_with(phone_call, location: api_twilio_account_call_url(current_account, phone_call))
      else
        respond_with(schema_validation_result)
      end
    end

    private

    def association_chain
      current_account.phone_calls
    end
  end
end
