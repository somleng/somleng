require "rails_helper"

RSpec.describe ProcessCDR do
  it "creates a call data record" do
    cdr = build_cdr(
      variables: {
        sip_term_status: "487",
        answer_epoch: "0",
        start_epoch: "1474362923",
        end_epoch: "1474362924"
      }
    )

    phone_call = create(
      :phone_call, :initiated, :with_status_callback_url,
      id: cdr.dig("variables", "sip_rh_X-Somleng-CallSid")
    )

    ProcessCDR.call(compress(cdr))

    expect(phone_call.reload.status).to eq("not_answered")
    expect(phone_call.call_data_record).to have_attributes(
      start_time: Time.utc(2016, 9, 20, 9, 15, 23),
      end_time: Time.utc(2016, 9, 20, 9, 15, 24),
      answer_time: nil,
      sip_term_status: "487"
    )
    expect(phone_call.call_data_record.call_leg.A?).to eq(true)
    expect(phone_call.call_data_record.file.attached?).to eq(true)
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(
      "TwilioAPI::NotifyWebhook",
      account: phone_call.account,
      url: phone_call.status_callback_url,
      http_method: phone_call.status_callback_method,
      params: hash_including("CallStatus" => "no-answer")
    )
  end

  it "creates a call data record for a failed inbound call" do
    cdr = build_cdr(
      variables: {
        "uuid" => SecureRandom.uuid,
        "sip_rh_X-Somleng-CallSid" => nil,
        "sip_h_X-Somleng-CallSid" => nil
      }
    )

    phone_call = create(
      :phone_call, :initiated, external_id: cdr.dig("variables", "uuid")
    )

    ProcessCDR.call(compress(cdr))

    expect(phone_call.call_data_record).to be_present
  end

  it "creates a call data record for an outbound call" do
    cdr = build_cdr(from: "freeswitch_cdr_outbound.json")

    phone_call = create(
      :phone_call, :initiated, :with_status_callback_url,
      id: cdr.dig("variables", "sip_h_X-Somleng-CallSid")
    )

    ProcessCDR.call(compress(cdr))

    expect(phone_call.call_data_record).to be_present
  end

  it "creates an event" do
    cdr = build_cdr

    phone_call = create(
      :phone_call, :initiated,
      id: cdr.dig("variables", "sip_rh_X-Somleng-CallSid")
    )

    ProcessCDR.call(compress(cdr))

    expect(phone_call.events.first).to have_attributes(
      type: "phone_call.completed",
      carrier: phone_call.carrier
    )
  end

  it "creates a call data record for call leg A with joined by call leg B" do
    cdr = build_cdr(from: "freeswitch_cdr_leg_a_with_joined_by_leg_b.json")

    phone_call = create(
      :phone_call, :initiated, :with_status_callback_url,
      id: cdr.dig("variables", "sip_rh_X-Somleng-CallSid")
    )

    ProcessCDR.call(compress(cdr))

    expect(phone_call.call_data_record.call_leg.A?).to eq(true)
    expect(ExecuteWorkflowJob).to have_been_enqueued.with("TwilioAPI::NotifyWebhook", any_args)
  end

  it "creates a call data record for call leg B" do
    leg_a_cdr = build_cdr(from: "freeswitch_cdr_leg_a_with_joined_by_leg_b.json")
    leg_b_cdr = build_cdr(from: "freeswitch_cdr_leg_b.json")

    phone_call = create(
      :phone_call, :initiated, :with_status_callback_url,
      id: leg_a_cdr.dig("variables", "sip_rh_X-Somleng-CallSid")
    )
    leg_a_call_data_record = create(:call_data_record, call_leg: "A", phone_call:)

    ProcessCDR.call(compress(leg_b_cdr))

    expect(phone_call.call_data_record).to eq(leg_a_call_data_record)
    expect(CallDataRecord.where(phone_call:).last.call_leg.B?).to eq(true)
    expect(ExecuteWorkflowJob).not_to have_been_enqueued.with("TwilioAPI::NotifyWebhook", any_args)
  end

  def build_cdr(from: "freeswitch_cdr.json", variables: {})
    cdr = JSON.parse(file_fixture(from).read)
    cdr["variables"].merge!(variables.stringify_keys)
    cdr
  end

  def compress(cdr)
    Base64.encode64(ActiveSupport::Gzip.compress(cdr.to_json))
  end
end
