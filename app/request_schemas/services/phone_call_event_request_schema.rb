module Services
  class PhoneCallEventRequestSchema < ServicesRequestSchema
    params do
      required(:type).value(:str?, included_in?: PhoneCallEvent.type.values)
      required(:phone_call).value(:str?)
      optional(:variables).maybe(:hash?)
    end
  end
end
