require 'rails_helper'

describe PhoneCallEvent::CompletedObserver do
  let(:phone_call) { create(:phone_call, :answered) }
  let(:phone_call_event) { create(:phone_call_event_completed, :phone_call => phone_call) }

  def setup_scenario
    subject.phone_call_event_completed_created(phone_call_event)
  end

  before do
    setup_scenario
  end

  def assert_observed!
    expect(phone_call.completed_event).to eq(phone_call_event)
    expect(phone_call).to be_completed
  end

  it { assert_observed! }
end
