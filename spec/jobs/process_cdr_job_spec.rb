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

    ProcessCDRJob.perform_now(freeswitch_cdr)

    expect(phone_call.reload.status).to eq("not_answered")
    expect(phone_call.call_data_record).to have_attributes(
      start_time: Time.utc(2016, 9, 20, 9, 15, 23),
      end_time: Time.utc(2016, 9, 20, 9, 15, 24),
      answer_time: nil,
      sip_term_status: "487"
    )
    expect(phone_call.call_data_record.call_leg.A?).to eq(true)
    expect(phone_call.call_data_record.file.attached?).to eq(true)
    expect(ExecuteWorkflowJob).to have_been_enqueued.with("NotifyPhoneCallStatusCallback", phone_call)
  end

  it "creates an event" do
    raw_freeswitch_cdr = file_fixture("freeswitch_cdr.json").read
    freeswitch_cdr = JSON.parse(raw_freeswitch_cdr)

    phone_call = create(
      :phone_call, :initiated,
      external_id: freeswitch_cdr.dig("variables", "uuid")
    )

    ProcessCDRJob.perform_now(freeswitch_cdr)

    event = Event.find_by(eventable_id: phone_call.id)
    expect(event).to have_attributes(
      type: "phone_call.completed",
      carrier: phone_call.carrier
    )
  end

  it "creates a call data record for call leg A with joined by call leg B" do
    raw_freeswitch_cdr = file_fixture("freeswitch_cdr_leg_a_with_joined_by_leg_b.json").read
    freeswitch_cdr = JSON.parse(raw_freeswitch_cdr)

    phone_call = create(
      :phone_call, :initiated, :with_status_callback_url,
      external_id: freeswitch_cdr.dig("variables", "uuid")
    )

    ProcessCDRJob.perform_now(freeswitch_cdr)

    expect(phone_call.call_data_record.call_leg.A?).to eq(true)
    expect(ExecuteWorkflowJob).to have_been_enqueued.with("NotifyPhoneCallStatusCallback", phone_call)
  end

  it "creates a call data record for call leg B" do
    raw_freeswitch_cdr_call_leg_a = file_fixture("freeswitch_cdr_leg_a_with_joined_by_leg_b.json").read
    freeswitch_cdr_call_leg_a = JSON.parse(raw_freeswitch_cdr_call_leg_a)

    raw_freeswitch_cdr_call_leg_b = file_fixture("freeswitch_cdr_leg_b.json").read
    freeswitch_cdr_call_leg_b = JSON.parse(raw_freeswitch_cdr_call_leg_b)

    phone_call = create(
      :phone_call, :initiated, :with_status_callback_url,
      external_id: freeswitch_cdr_call_leg_a.dig("variables", "uuid")
    )
    call_data_record_call_leg_a = create(:call_data_record, call_leg: "A", phone_call: phone_call)

    ProcessCDRJob.perform_now(freeswitch_cdr_call_leg_b)

    expect(phone_call.call_data_record).to eq(call_data_record_call_leg_a)
    expect(CallDataRecord.where(phone_call: phone_call).last.call_leg.B?).to eq(true)
    expect(ExecuteWorkflowJob).not_to have_been_enqueued.with("NotifyPhoneCallStatusCallback", phone_call)
  end
end
