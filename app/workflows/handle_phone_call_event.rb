class HandlePhoneCallEvent < ApplicationWorkflow
  attr_reader :event_params, :event

  EVENT_MAPPING = {
    ringing: :ring,
    answered: :answer,
    completed: :complete
  }.freeze

  def initialize(event_params)
    @event_params = event_params
  end

  def call
    PhoneCallEvent.transaction do
      create_event
      update_phone_call
      handle_event
      event
    end
  end

  private

  def create_event
    @event = PhoneCallEvent.create!(event_params)
  end

  def update_phone_call
    phone_call.aasm.fire!(EVENT_MAPPING.fetch(event.type.to_sym))
  end

  def phone_call
    event.phone_call
  end

  def handle_event
    notify_status_callback_url if event.type == "completed"
  end

  def notify_status_callback_url
    return if phone_call.status_callback_url.blank?

    StatusCallbackNotifierJob.perform_later(phone_call)
  end
end
