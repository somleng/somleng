require 'rails_helper'

describe CallDataRecordJob do
  describe "#perform(cdr)" do
    let(:cdr) { { "some" => "params"}.to_json }
    let(:call_data_record) { instance_double(CallDataRecord) }

    def assert_active_job_performed!
      allow(CallDataRecord).to receive(:new).and_return(call_data_record)
      allow(call_data_record).to receive(:process)
      expect(call_data_record).to receive(:process).with(cdr)
      subject.perform(cdr)
    end

    it { assert_active_job_performed! }
  end
end
