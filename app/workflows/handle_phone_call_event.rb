class HandlePhoneCallEvent < ApplicationWorkflow
  attr_reader :event_params

  def initialize(event_params)
    @event_params = event_params
  end

  def call
    event = create_event
  end

  private

  def create_event
    PhoneCallEvent.create!(event_params)
  end
end
