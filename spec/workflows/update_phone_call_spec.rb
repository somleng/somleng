require "rails_helper"

RSpec.describe UpdatePhoneCall do
  it "handles completed events for queued calls" do
    phone_call = create(:phone_call, :queued)
    client = build_fake_client

    UpdatePhoneCall.call(phone_call, client:, status: :completed)

    expect(phone_call.reload).to have_attributes(
      status: "canceled",
      user_terminated_at: be_present
    )
    expect(client).not_to have_been_enqueued
  end

  it "handles completed events for live calls" do
    phone_call = create(:phone_call, :initiated)
    client = build_fake_client

    UpdatePhoneCall.call(phone_call, client:, status: :completed)

    expect(phone_call.reload).to have_attributes(
      status: "initiated",
      user_terminated_at: be_present
    )
    expect(client).to have_been_enqueued.with(phone_call)
  end

  it "updates a queued call" do
    phone_call = create(:phone_call, :queued, twiml: "<Response><Say>Hello World</Say></Response>")
    client = build_fake_client

    UpdatePhoneCall.call(
      phone_call,
      client:,
      voice_url: "https://www.example.com/new-voice.xml",
      voice_method: "GET",
      twiml: nil
    )

    expect(phone_call.reload).to have_attributes(
      voice_url: "https://www.example.com/new-voice.xml",
      voice_method: "GET",
      user_updated_at: be_present,
      twiml: nil
    )
    expect(client).not_to have_been_enqueued
  end

  it "updates a live call" do
    phone_call = create(:phone_call, :initiated, voice_url: "https://example.com/voice.xml")
    client = build_fake_client

    UpdatePhoneCall.call(
      phone_call,
      client:,
      twiml: "<Response><Say>Hello from updated TwiML</Say></Response>",
      voice_url: nil
    )

    expect(phone_call.reload).to have_attributes(
      twiml: "<Response><Say>Hello from updated TwiML</Say></Response>",
      user_updated_at: be_present,
      voice_url: nil
    )
    expect(client).to have_been_enqueued.with(phone_call)
  end

  it "updates status callback parameters" do
    phone_call = create(:phone_call, :initiated)
    client = build_fake_client

    UpdatePhoneCall.call(
      phone_call,
      client:,
      status_callback_url: "https://www.example.com/new-status-callback.xml",
      status_callback_method: "GET"
    )
    expect(client).not_to have_been_enqueued
  end

  def build_fake_client
    Class.new(UpdateLiveCallJob) do
      self.queue_adapter = ApplicationJob.queue_adapter
    end
  end
end
