require 'rails_helper'

describe PhoneCallEvent::RecordingCompletedObserver do
  let(:phone_call_event) { create(:phone_call_event_recording_completed) }
  let(:enqueued_job) { enqueued_jobs.first }

  def setup_scenario
    subject.phone_call_event_recording_completed_created(phone_call_event)
  end

  before do
    setup_scenario
  end

  def assert_observed!
    expect(enqueued_job[:job]).to eq(RecordingProcessorJob)
    expect(enqueued_job[:args]).to match_array([phone_call_event.id])
  end

  it { assert_observed! }
end

