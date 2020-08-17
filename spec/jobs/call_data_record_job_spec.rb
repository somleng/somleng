require 'rails_helper'

describe CallDataRecordJob do
  describe "#perform(cdr)" do
    let(:freeswitch_cdr) { build(:freeswitch_cdr) }
    let(:raw_cdr) { freeswitch_cdr.raw_cdr }
    let(:call_data_record) { subject.perform(raw_cdr) }

    def setup_scenario
      call_data_record
    end

    before do
      setup_scenario
    end

    context "phone call not found" do
      def assert_cdr_processed!
        expect(call_data_record).not_to be_persisted
      end

      it { assert_cdr_processed! }
    end

    context "phone call found" do
      let(:phone_call) { create(:phone_call, :initiated, :external_id => freeswitch_cdr.uuid) }

      def setup_scenario
        phone_call
        super
      end

      def assert_cdr_processed!
        expect(call_data_record).to be_persisted
        expect(call_data_record.phone_call).to eq(phone_call)
        expect(call_data_record.direction).to eq(freeswitch_cdr.direction)
        expect(call_data_record.bill_sec).to eq(freeswitch_cdr.bill_sec.to_i)
        expect(call_data_record.duration_sec).to eq(freeswitch_cdr.duration_sec.to_i)
        expect(call_data_record.start_time).to eq(Time.at(freeswitch_cdr.start_epoch.to_i))
        expect(call_data_record.end_time).to eq(Time.at(freeswitch_cdr.end_epoch.to_i))
        expect(call_data_record.answer_time).to eq(nil)
        expect(call_data_record.sip_term_status).to eq(freeswitch_cdr.sip_term_status)
        expect(call_data_record.sip_invite_failure_status).to eq(freeswitch_cdr.sip_invite_failure_status)
        expect(call_data_record.sip_invite_failure_phrase).to eq(freeswitch_cdr.sip_invite_failure_phrase)
        expect(call_data_record.price).to eq(0)
      end

      it { assert_cdr_processed! }
    end
  end
end
