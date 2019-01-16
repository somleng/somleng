require "rails_helper"

RSpec.describe CreatePhoneCallEvent do
  it "creates a phone call event" do
    phone_call = create(:phone_call)
    params = build_event_params(
      phone_call: phone_call,
      type: :recording_started,
      params: { "foo" => "bar" }
    )

    described_class.call(params)

    phone_call_event = PhoneCallEvent.last
    expect(phone_call_event.phone_call).to eq(phone_call)
    expect(phone_call_event.type).to eq("recording_started")
    expect(phone_call_event.params).to eq("foo" => "bar")
  end

  it "handles recording started events" do
    allow(HandleRecordingStartedEvent).to receive(:call)

    described_class.call(build_event_params(type: :recording_started))

    expect(HandleRecordingStartedEvent).to have_received(:call).with(PhoneCallEvent.last)
  end

  it "handles ringing events" do
    allow(HandleRingingEvent).to receive(:call)

    described_class.call(build_event_params(type: :ringing))

    expect(HandleRingingEvent).to have_received(:call).with(PhoneCallEvent.last)
  end

  it "handles answered events" do
    allow(HandleAnsweredEvent).to receive(:call)

    described_class.call(build_event_params(type: :answered))

    expect(HandleAnsweredEvent).to have_received(:call).with(PhoneCallEvent.last)
  end

  it "handles completed events" do
    allow(HandleCompletedEvent).to receive(:call)

    described_class.call(build_event_params(type: :completed))

    expect(HandleCompletedEvent).to have_received(:call).with(PhoneCallEvent.last)
  end

  it "handles recording completed events" do
    allow(HandleRecordingCompletedEvent).to receive(:call)

    described_class.call(build_event_params(type: :recording_completed))

    expect(HandleRecordingCompletedEvent).to have_received(:call).with(PhoneCallEvent.last)
  end

  it "ignores unhandled events" do
    described_class.call(build_event_params(type: :foo))
    
  end

  def build_event_params(type:, **options)
    phone_call = options.delete(:phone_call) || create(:phone_call)
    params = options.delete(:params) || {}
    {
      phone_call_id: phone_call.id,
      type: type,
      params: params
    }
  end
end
