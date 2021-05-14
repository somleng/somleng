class PhoneCallStatusEvent
  attr_reader :phone_call

  EVENTS = {
    "completed" => :complete,
    "canceled" => :cancel
  }.freeze

  def initialize(phone_call)
    @phone_call = phone_call
  end

  def may_transition_to?(new_state)
    return false unless EVENTS.key?(new_state)

    phone_call.may_fire_event?(EVENTS.fetch(new_state))
  end
end
