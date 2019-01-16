require "rails_helper"

describe FreeswitchCDR do
  it "parses a FreeSWITCH CDR" do
    freeswitch_cdr = build(:freeswitch_cdr)

    expect(freeswitch_cdr).to have_attributes(
      uuid: "1b17f1e5-becb-4daa-8cb8-1ec822dd4297",
      direction: "inbound",
      duration_sec: 1,
      bill_sec: 0,
      hangup_cause: "ORIGINATOR_CANCEL",
      start_time: Time.utc(2016, 9, 20, 9, 15, 23),
      end_time: Time.utc(2016, 9, 20, 9, 15, 24),
      answer_time: nil,
      sip_term_status: "487",
      sip_invite_failure_status: "487",
      sip_invite_failure_phrase: "Internal Server Error",
      content_type: "application/json",
      filename: "a_1b17f1e5-becb-4daa-8cb8-1ec822dd4297.cdr.json"
    )
    expect(freeswitch_cdr.io.read).to eq(freeswitch_cdr.raw_data)
  end
end
