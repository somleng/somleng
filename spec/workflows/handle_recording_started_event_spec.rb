require "rails_helper"

RSpec.describe HandleRecordingStartedEvent do
  it "handles recording started events" do
    event = create(:phone_call_event, :recording_started)

    described_class.call(event)

    expect(event.reload.recording).to be_present
    expect(event.recording.twiml_instructions).to eq(event.params)
    expect(event.recording.phone_call).to eq(event.phone_call)
    expect(event.recording.phone_call.recording).to eq(event.recording)
  end
end
