require "rails_helper"

RSpec.describe HandlePhoneCallEvent do
  it "creates events" do
    phone_call = create(:phone_call, :initiated)

    event = HandlePhoneCallEvent.call(
      phone_call: phone_call,
      type: "ringing",
      params: {
        "sip_term_status" => "200",
        "answer_epoch" => "1585814727"
      }
    )

    expect(event).to have_attributes(
      persisted?: true,
      phone_call: phone_call,
      type: "ringing",
      params: {
        "sip_term_status" => "200",
        "answer_epoch" => "1585814727"
      }
    )
  end

  it "handles ringing events" do
    phone_call = create(:phone_call, :initiated)

    HandlePhoneCallEvent.call(
      phone_call: phone_call,
      type: "ringing"
    )

    expect(phone_call.status).to eq("ringing")
  end

  it "handles answered events" do
    phone_call = create(:phone_call, :initiated)

    HandlePhoneCallEvent.call(
      phone_call: phone_call,
      type: "answered"
    )

    expect(phone_call.status).to eq("answered")
  end

  it "handles completed events" do
    phone_call = create(
      :phone_call,
      :answered,
      status_callback_url: "https://www.example.com/status_callback"
    )

    HandlePhoneCallEvent.call(
      phone_call: phone_call,
      type: "completed"
    )

    expect(phone_call.status).to eq("completed")
    expect(StatusCallbackNotifierJob).to have_been_enqueued.with(phone_call)
  end
end
