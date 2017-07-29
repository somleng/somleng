require 'rails_helper'

describe PhoneCallEvent::RingingObserver do
  include Twilreapi::SpecHelpers::ObserverHelpers::PhoneCallEvent::ObserverExamples

  let(:phone_call_event_type) { PhoneCallEvent::Ringing }
  let(:asserted_phone_call_event) { :ring! }

  def trigger_event!
    subject.phone_call_event_ringing_created(phone_call_event)
  end

  include_examples("phone_call_event_observer")
end
