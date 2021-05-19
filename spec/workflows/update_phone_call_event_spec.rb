require "rails_helper"

RSpec.describe UpdatePhoneCallStatus do
  it "handles ringing events" do
    phone_call = create(:phone_call, :initiated)

    UpdatePhoneCallStatus.call(
      phone_call,
      event_type: "ringing",
      answer_epoch: "0",
      sip_term_status: ""
    )

    expect(phone_call.status).to eq("ringing")
  end

  it "handles answered events" do
    phone_call = create(:phone_call, :initiated)

    UpdatePhoneCallStatus.call(
      phone_call,
      event_type: "answered",
      answer_epoch: 0,
      sip_term_status: ""
    )

    expect(phone_call.status).to eq("answered")
  end

  it "handles completed events" do
    phone_call = create(:phone_call, :answered)

    UpdatePhoneCallStatus.call(
      phone_call,
      event_type: "completed",
      sip_term_status: "200",
      answer_epoch: "1585814727"
    )

    expect(phone_call.status).to eq("completed")
  end

  it "handles completed events with not answered" do
    phone_call = create(:phone_call, :ringing)

    UpdatePhoneCallStatus.call(
      phone_call,
      event_type: "completed",
      answer_epoch: "0",
      sip_term_status: "487"
    )

    expect(phone_call.status).to eq("not_answered")
  end

  it "handles completed events with " do
    phone_call = create(:phone_call, :ringing)

    UpdatePhoneCallStatus.call(
      phone_call,
      event_type: "completed",
      answer_epoch: nil,
      sip_term_status: nil,
      sip_invite_failure_status: "487"
    )

    expect(phone_call.status).to eq("canceled")
  end

  it "handles completed events with busy" do
    phone_call = create(:phone_call, :ringing)

    UpdatePhoneCallStatus.call(
      phone_call,
      event_type: "completed",
      answer_epoch: "0",
      sip_term_status: "486"
    )

    expect(phone_call.status).to eq("busy")
  end
end
