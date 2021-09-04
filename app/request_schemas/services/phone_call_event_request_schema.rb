module Services
  class PhoneCallEventRequestSchema < ServicesRequestSchema
    params do
      required(:type).value(:str?, included_in?: PhoneCallEvent.type.values)
      required(:phone_call).value(:str?)
      optional(:variables).maybe(:hash?)
    end

    def output
      params = super
      result = {}
      result[:type] = params.fetch(:type)
      result[:phone_call] = params.fetch(:phone_call)
      result[:params] = params.fetch(:variables) if params.key?(:variables)
      result
    end
  end
end
