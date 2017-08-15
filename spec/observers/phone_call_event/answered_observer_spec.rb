require 'rails_helper'

describe PhoneCallEvent::AnsweredObserver do
  let(:phone_call) { create(:phone_call, :initiated) }
  let(:phone_call_event) { create(:phone_call_event_answered, :phone_call => phone_call) }

  def setup_scenario
    subject.phone_call_event_answered_created(phone_call_event)
  end

  before do
    setup_scenario
  end

  def assert_observed!
    expect(phone_call).to be_answered
  end

  it { assert_observed! }
end
