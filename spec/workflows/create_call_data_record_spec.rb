require "rails_helper"

describe CreateCallDataRecord do
  it "creates a call data record" do
    freeswitch_cdr = build(:freeswitch_cdr)
    phone_call = create(:phone_call, external_id: freeswitch_cdr.uuid)

    call_data_record = described_class.call(freeswitch_cdr.raw_data)

    expect(call_data_record).to have_attributes(
      phone_call: phone_call,
      direction: freeswitch_cdr.direction,
      bill_sec: freeswitch_cdr.bill_sec,
      duration_sec: freeswitch_cdr.duration_sec,
      start_time: freeswitch_cdr.start_time,
      end_time: freeswitch_cdr.end_time,
      answer_time: freeswitch_cdr.answer_time,
      sip_term_status: freeswitch_cdr.sip_term_status,
      sip_invite_failure_status: freeswitch_cdr.sip_invite_failure_status,
      sip_invite_failure_phrase: freeswitch_cdr.sip_invite_failure_phrase,
      price: 0,
      file: be_present
    )
  end
end
