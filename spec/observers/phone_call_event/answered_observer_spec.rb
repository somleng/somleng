require 'rails_helper'

describe PhoneCallEvent::AnsweredObserver do
  include Twilreapi::SpecHelpers::ObserverHelpers::PhoneCallEvent::ObserverExamples

  let(:phone_call_event_type) { PhoneCallEvent::Answered }
  let(:asserted_phone_call_event) { :answer! }

  def trigger_event!
    subject.phone_call_event_answered_created(phone_call_event)
  end

  include_examples("phone_call_event_observer")
end
