require 'rails_helper'

describe PhoneCallEvent::RecordingStartedObserver do
  let(:phone_call_event) { create(:phone_call_event_recording_started) }

  def setup_scenario
    subject.phone_call_event_recording_started_created(phone_call_event)
  end

  before do
    setup_scenario
  end

  def assert_observed!
  end

  it { assert_observed! }
end

