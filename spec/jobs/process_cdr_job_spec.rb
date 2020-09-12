require "rails_helper"

RSpec.describe ProcessCDRJob do
  it "creates a call data record" do
    raw_freeswitch_cdr = file_fixture("freeswitch_cdr.json").read
    freeswitch_cdr = JSON.parse(raw_freeswitch_cdr)
    freeswitch_cdr["variables"]["sip_term_status"] = "487"
    freeswitch_cdr["variables"]["answer_epoch"] = "0"
    freeswitch_cdr["variables"]["start_epoch"] = "1474362923"
    freeswitch_cdr["variables"]["end_epoch"] = "1474362924"

    phone_call = create(
      :phone_call, :initiated, :with_status_callback_url,
      external_id: freeswitch_cdr.dig("variables", "uuid")
    )

    ProcessCDRJob.new.perform(freeswitch_cdr)

    expect(phone_call.reload.status).to eq("not_answered")
    expect(phone_call.call_data_record).to have_attributes(
      start_time: Time.local(2016, 9, 20, 16, 15, 23),
      end_time: Time.local(2016, 9, 20, 16, 15, 24),
      answer_time: nil,
      sip_term_status: "487"
    )
    expect(phone_call.call_data_record.file.attached?).to eq(true)
    expect(StatusCallbackNotifierJob).to have_been_enqueued.with(phone_call)
  end

  it "handles phone call not found" do
    raw_freeswitch_cdr = file_fixture("freeswitch_cdr.json").read
    freeswitch_cdr = JSON.parse(raw_freeswitch_cdr)

    ProcessCDRJob.new.perform(freeswitch_cdr)

    expect(CallDataRecord.count).to eq(0)
  end
end
