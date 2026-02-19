module APIResponseSchema
  module Services
    OutboundPhoneCallsSchema = Dry::Schema.JSON do
      required(:phone_calls).value(:array).each do
        schema do
          required(:sid).filled(:str?)
          required(:account_sid).filled(:str?)
          required(:carrier_sid).filled(:str?)
          required(:parent_call_sid).filled(:str?)
          required(:from).filled(:str?)
          required(:direction).filled(:str?)
          required(:routing_parameters).maybe(:hash?) do
            schema do
              required(:address).maybe(:str?)
              required(:destination).filled(:str?)
              required(:dial_string_prefix).maybe(:str?)
              required(:plus_prefix).filled(:bool?)
              required(:national_dialing).filled(:bool?)
              required(:host).filled(:str?)
              required(:username).maybe(:str?)
              required(:sip_profile).filled(:str?)
            end
          end
          required(:billing_parameters).maybe(:hash?) do
            schema do
              required(:enabled).filled(:bool?)
              required(:category).filled(:str?)
              required(:billing_mode).filled(:str?)
            end
          end
        end
      end
    end
  end
end
