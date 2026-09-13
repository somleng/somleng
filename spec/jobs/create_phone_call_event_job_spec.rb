require "rails_helper"

RSpec.describe CreatePhoneCallEventJob do
  it "handles ringing events" do
    phone_call = create(:phone_call, :initiated)

    CreatePhoneCallEventJob.perform_now(
      phone_call_external_id: phone_call.external_id,
      type: "ringing",
      params: {
        "foo" => "bar"
      }
    )

    expect(phone_call.reload).to have_attributes(
      status: "ringing",
      phone_call_events: contain_exactly(
        have_attributes(
          type: "ringing",
          params: {
            "foo" => "bar"
          }
        )
      )
    )
  end

  it "handles answered events" do
    phone_call = create(:phone_call, :initiated)

    CreatePhoneCallEventJob.perform_now(
      phone_call_external_id: phone_call.external_id,
      type: "answered"
    )

    expect(phone_call.reload).to have_attributes(
      status: "answered",
      phone_call_events: contain_exactly(
        have_attributes(
          type: "answered"
        )
      )
    )
  end

  it "handles completed events" do
    phone_call = create(:phone_call, :initiated)

    CreatePhoneCallEventJob.perform_now(
      phone_call_external_id: phone_call.external_id,
      type: "completed"
    )

    expect(phone_call.reload).to have_attributes(
      status: "initiated",
      phone_call_events: contain_exactly(
        have_attributes(
          type: "completed"
        )
      )
    )
  end

  it "retries if the phone call is not found" do
    allow(Rails.logger).to receive(:warn)

    perform_enqueued_jobs do
      CreatePhoneCallEventJob.perform_now(
        phone_call_external_id: SecureRandom.uuid,
        type: "answered"
      )
    end

    expect(Rails.logger).to have_received(:warn).with(
      a_string_matching(/CreatePhoneCallEventJob.*giving up after 3 attempts/i)
    )
  end

  it "handles invalid state transitions" do
    phone_call = create(:phone_call, :completed)

    CreatePhoneCallEventJob.perform_now(
      phone_call_external_id: phone_call.external_id,
      type: "answered"
    )

    expect(phone_call.reload).to have_attributes(
      status: "completed",
      phone_call_events: contain_exactly(
        have_attributes(
          type: "answered"
        )
      )
    )
  end
end
