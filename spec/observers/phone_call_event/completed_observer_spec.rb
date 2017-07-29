require 'rails_helper'

describe PhoneCallEvent::CompletedObserver do
  include Twilreapi::SpecHelpers::ObserverHelpers::PhoneCallEvent::ObserverExamples

  let(:phone_call_event_type) { PhoneCallEvent::Completed }
  let(:asserted_phone_call_event) { :complete! }

  def setup_scenario
    allow(phone_call).to receive(:completed_event=)
    super
  end

  def setup_expectations
    expect(phone_call).to receive(:completed_event=).with(phone_call_event)
    super
  end

  def trigger_event!
    subject.phone_call_event_completed_created(phone_call_event)
  end

  include_examples("phone_call_event_observer")
end
