require "rails_helper"

RSpec.describe UpdateLiveCallJob do
  it "ends a call" do
    phone_call = create(
      :phone_call,
      :initiated,
      :user_terminated,
      external_id: "external-id",
      call_service_host: "10.10.1.13"
    )
    call_service_client = instance_spy(CallService::Client, end_call: OpenStruct.new(success?: true))

    UpdateLiveCallJob.perform_now(phone_call, call_service_client:)

    expect(call_service_client).to have_received(:end_call).with(
      host: have_attributes(to_s: "10.10.1.13"), id: "external-id"
    )
  end

  it "updates a call with a new Voice URL" do
    phone_call = create(
      :phone_call,
      :initiated,
      :user_updated,
      external_id: "external-id",
      call_service_host: "10.10.1.13",
      voice_url: "https://example.com/voice.xml",
      voice_method: "POST"
    )
    call_service_client = instance_spy(CallService::Client, update_call: OpenStruct.new(success?: true))

    UpdateLiveCallJob.perform_now(phone_call, call_service_client:)

    expect(call_service_client).to have_received(:update_call).with(
      host: have_attributes(to_s: "10.10.1.13"),
      id: "external-id",
      voice_url: "https://example.com/voice.xml",
      voice_method: "POST"
    )
  end

  it "updates a call with new TwiML" do
    phone_call = create(
      :phone_call,
      :initiated,
      :user_updated,
      external_id: "external-id",
      call_service_host: "10.10.1.13",
      voice_url: nil,
      twiml: "<Response><Say>Ahoy there!</Say></Response>"
    )
    call_service_client = instance_spy(CallService::Client, update_call: OpenStruct.new(success?: true))

    UpdateLiveCallJob.perform_now(phone_call, call_service_client:)

    expect(call_service_client).to have_received(:update_call).with(
      host: have_attributes(to_s: "10.10.1.13"),
      id: "external-id",
      twiml: "<Response><Say>Ahoy there!</Say></Response>"
    )
  end

  it "retries failed attempts" do
    phone_call = create(
      :phone_call,
      :initiated,
      :user_terminated,
      external_id: "external-id",
      call_service_host: "10.10.1.13"
    )
    call_service_client = instance_spy(CallService::Client, end_call: OpenStruct.new(success?: false))

    expect {
      UpdateLiveCallJob.perform_now(phone_call, call_service_client:)
    }.to raise_error(UpdateLiveCallJob::RetryJob)

    expect(call_service_client).to have_received(:end_call)
  end
end
