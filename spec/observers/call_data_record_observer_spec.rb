require 'rails_helper'

describe CallDataRecordObserver do
  describe "#call_data_record_created(call_data_record)" do
    let(:phone_call) { instance_double(PhoneCall) }
    let(:call_data_record) { instance_double(CallDataRecord, :phone_call => phone_call) }

    before do
      setup_expectations
    end

    def setup_scenario
      setup_expectations
    end

    def setup_expectations
      expect(phone_call).to receive(:complete!)
    end

    def trigger_event!
      subject.call_data_record_created(call_data_record)
    end

    it { trigger_event! }
  end
end
