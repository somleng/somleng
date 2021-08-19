module Services
  class PhoneCallEventRequestSchema < ApplicationRequestSchema
    params do
      required(:type).value(:str?, included_in?: PhoneCallEvent.type.values)
      required(:phone_call).value(:str?)
      optional(:variables).maybe(:hash?)
    end

    rule(:phone_call) do
      phone_call = find_phone_call(value)
      key("phone_call").failure("does not exist") if phone_call.blank?
    end

    def output
      params = super
      result = {}
      result[:type] = params.fetch(:type)
      result[:phone_call] = find_phone_call(params.fetch(:phone_call))
      result[:params] = params.fetch(:variables) if params.key?(:variables)
      result
    end

    private

    def find_phone_call(external_id)
      PhoneCall.find_by(external_id: external_id)
    end
  end
end
