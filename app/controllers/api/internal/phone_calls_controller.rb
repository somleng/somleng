module API
  module Internal
    class PhoneCallsController < BaseController
      def create
        schema_validation_result = PhoneCallRequestSchema.schema.call(request.params)
        if schema_validation_result.success?
          phone_call = CreatePhoneCall.call(
            attributes: schema_validation_result.output,
            account: current_account
          )
          respond_with(phone_call, location: api_internal_phone_call_url(phone_call))
        else
          respond_with(schema_validation_result)
        end
      end

      private

      def association_chain
        PhoneCall.all
      end

      def save_resource
        resource.initiate_inbound_call
      end
    end
  end
end
