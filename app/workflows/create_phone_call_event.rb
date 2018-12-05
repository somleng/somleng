class CreatePhoneCallEvent < ApplicationWorkflow
  attr_accessor :params

  def initialize(params)
    self.params = params
  end

  def call
    event = create_phone_call_event
    handle_event(event)
  end

  private

  def create_phone_call_event
    PhoneCallEvent.create!(
      phone_call: phone_call,
      type: params.fetch(:type),
      params: params[:params]
    )
  end

  def handle_event(event)
    event_handler = "Handle#{event.type.camelize}Event".constantize
    ExecuteWorkflowJob(event_handler.to_s, event).perform_later
  rescue NameError
    Rails.logger.warn("Ignoring event. No handler for #{event.type} found")
  end

  def phone_call
    @phone_call ||= PhoneCall.find_by_uuid!(params[:phone_call_id])
  end
end
