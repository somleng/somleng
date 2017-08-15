require 'rails_helper'

describe PhoneCallEvent::RingingObserver do
  let(:phone_call) { create(:phone_call, :initiated) }
  let(:phone_call_event) { create(:phone_call_event_ringing, :phone_call => phone_call) }

  def setup_scenario
    subject.phone_call_event_ringing_created(phone_call_event)
  end

  before do
    setup_scenario
  end

  def assert_observed!
    expect(phone_call).to be_ringing
  end

  it { assert_observed! }
end
