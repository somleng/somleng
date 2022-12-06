class CreateEvent < ApplicationWorkflow
  attr_reader :eventable, :type, :event

  def initialize(eventable:, type:)
    @eventable = eventable
    @type = type
  end

  def call
    create_event
    notify_webhook if carrier.webhooks_enabled?
    event
  end

  private

  def create_event
    @event = Event.create!(
      eventable:,
      carrier:,
      type:,
      details: eventable.jsonapi_serializer_class.new(eventable.decorated).as_json
    )
  end

  def notify_webhook
    ExecuteWorkflowJob.perform_later(
      NotifyWebhookEndpoint.to_s,
      carrier.webhook_endpoint,
      event
    )
  end

  def carrier
    eventable.carrier
  end
end
