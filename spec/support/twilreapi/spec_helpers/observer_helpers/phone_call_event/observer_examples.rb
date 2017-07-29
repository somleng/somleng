module Twilreapi::SpecHelpers::ObserverHelpers::PhoneCallEvent::ObserverExamples
  def phone_call
    @phone_call ||= instance_double(PhoneCall)
  end

  def phone_call_event
    @phone_call_event ||= instance_double(phone_call_event_type, :phone_call => phone_call)
  end

  def setup_scenario
    setup_expectations
  end

  def setup_expectations
    expect(phone_call).to receive(asserted_phone_call_event)
  end
end

shared_examples_for "phone_call_event_observer" do
  before do
    setup_scenario
  end

  it { trigger_event! }
end
