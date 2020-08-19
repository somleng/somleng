class HandlePhoneCallEvent < ApplicationWorkflow
  attr_reader :event_params

  EVENT_MAPPING = {
    ringing: :ring
  }.freeze

  def initialize(event_params)
    @event_params = event_params
  end

  def call
    PhoneCallEvent.transaction do
      event = create_event
      event.phone_call.aasm.fire!(EVENT_MAPPING.fetch(event.type.to_sym))
      event
    end
  end

  private

  def create_event
    PhoneCallEvent.create!(event_params)
  end
end
