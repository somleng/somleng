require 'rails_helper'

describe OutboundCallJob do
  describe "#perform(phone_call_id)" do
    let(:phone_call_id) { "12345" }
    let(:phone_call) { instance_double(PhoneCall, :id => phone_call_id) }

    def assert_active_job_performed!
      allow(PhoneCall).to receive(:find).with(phone_call_id).and_return(phone_call)
      allow(phone_call).to receive(:initiate_outbound_call!)
      expect(phone_call).to receive(:initiate_outbound_call!)
      subject.perform(phone_call.id)
    end

    it { assert_active_job_performed! }
  end
end
