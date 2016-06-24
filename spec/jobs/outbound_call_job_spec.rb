require 'rails_helper'

describe OutboundCallJob do
  describe "#queue_name" do
    it { expect(subject.queue_name).to eq(Rails.application.secrets[:active_job_outbound_call_queue]) }
  end
end
