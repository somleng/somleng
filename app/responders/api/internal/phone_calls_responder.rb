class Api::Internal::PhoneCallsResponder < Api::BaseResponder
  def display(resource, given_options={})
    super(resource.to_internal_inbound_call_json, given_options)
  end
end
