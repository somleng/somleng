require 'rails_helper'

describe CallDataRecordObserver do
  describe "#call_data_record_created(call_data_record)" do
    let(:phone_call) { create(:phone_call, :initiated) }
    let(:call_data_record) { create(:call_data_record, :phone_call => phone_call) }

    before do
      setup_scenario
    end

    def setup_scenario
      subject.call_data_record_created(call_data_record)
    end

    it { expect(phone_call).not_to be_initiated }
  end
end
