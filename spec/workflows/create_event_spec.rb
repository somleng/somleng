require "rails_helper"

RSpec.describe CreateEvent do
  it "creates an event" do
    phone_call = create(:phone_call, :completed)

    event = CreateEvent.call(eventable: phone_call, type: "phone_call.completed")

    expect(event).to be_persisted
  end

  it "notifies the event to webhook endpoint" do
    carrier = create(:carrier)
    oauth_application = create(:oauth_application, owner: carrier)
    webhook_endpoint = create(:webhook_endpoint, oauth_application: oauth_application)
    phone_call = create(:phone_call, :completed, carrier: carrier)

    event = CreateEvent.call(eventable: phone_call, type: "phone_call.completed")

    expect(ExecuteWorkflowJob).to have_been_enqueued.with(
      NotifyWebhookEndpoint.name,
      webhook_endpoint,
      event
    )
  end
end
