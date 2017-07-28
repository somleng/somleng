require 'rails_helper'

describe PhoneCallEvent::Ringing do
  let(:factory) { :phone_call_event_ringing }
  include_examples("phone_call_event")
end
