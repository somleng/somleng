require "rails_helper"

RSpec.describe UpdatePhoneCall do
  it "handles completed events for queued calls" do
    phone_call = create(:phone_call, :queued)

    UpdatePhoneCall.call(phone_call, status: :completed)

    expect(phone_call.reload).to have_attributes(
      status: "canceled",
      user_terminated_at: be_present
    )
    expect(UpdateLiveCallJob).not_to have_been_enqueued
  end

  it "handles completed events for live calls" do
    phone_call = create(:phone_call, :initiated)

    UpdatePhoneCall.call(phone_call, status: :completed)

    expect(phone_call.reload).to have_attributes(
      status: "initiated",
      user_terminated_at: be_present
    )
    expect(UpdateLiveCallJob).to have_been_enqueued.with(phone_call)
  end

  it "updates a queued call" do
    phone_call = create(:phone_call, :queued, twiml: "<Response><Say>Hello World</Say></Response>")

    UpdatePhoneCall.call(
      phone_call,
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
    expect(UpdateLiveCallJob).not_to have_been_enqueued
  end

  it "updates a live call" do
    phone_call = create(:phone_call, :initiated, voice_url: "https://example.com/voice.xml")

    UpdatePhoneCall.call(
      phone_call,
      twiml: "<Response><Say>Hello from updated TwiML</Say></Response>",
      voice_url: nil
    )

    expect(phone_call.reload).to have_attributes(
      twiml: "<Response><Say>Hello from updated TwiML</Say></Response>",
      user_updated_at: be_present,
      voice_url: nil
    )
    expect(UpdateLiveCallJob).to have_been_enqueued.with(phone_call)
  end

  it "updates status callback parameters" do
    phone_call = create(:phone_call, :initiated)

    UpdatePhoneCall.call(
      phone_call,
      status_callback_url: "https://www.example.com/new-status-callback.xml",
      status_callback_method: "GET"
    )
    expect(UpdateLiveCallJob).not_to have_been_enqueued
  end
end
