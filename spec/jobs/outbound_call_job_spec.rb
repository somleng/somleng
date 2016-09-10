require 'rails_helper'

describe OutboundCallJob do
  describe "#perform(phone_call_json)" do
    let(:phone_call) { create(:phone_call) }
    let(:phone_call_json) { phone_call.to_json }
    let(:outbound_call_job) { instance_double(Twilreapi::Worker::Job::OutboundCallJob) }

    def assert_active_job_performed!
      allow(Twilreapi::Worker::Job::OutboundCallJob).to receive(:new).and_return(outbound_call_job)
      expect(outbound_call_job).to receive(:perform).with(phone_call.to_somleng_json)
      subject.perform(phone_call_json)
    end

    it { assert_active_job_performed! }
  end
end
