require "rails_helper"

RSpec.describe ProcessCDRJob do
  it "creates a call data record" do
    cdr = build_cdr(
      variables: {
        sip_term_status: "487",
        answer_epoch: "0",
        start_epoch: "1474362923",
        end_epoch: "1474362924",
        hangup_cause: "NORMAL_UNSPECIFIED",
        sip_invite_failure_phrase: "Temporary%20Unavailable"
      }
    )
    account = create(:account)
    phone_call = create(
      :phone_call, :initiated,
      id: cdr.dig("variables", "sip_rh_X-Somleng-CallSid"),
      account:
    )
    account_session_limiter, global_session_limiter = build_session_limiters(account:, sessions: { hydrogen: 2 })

    ProcessCDRJob.perform_now(encode(cdr.to_json))

    expect(phone_call).to have_attributes(
      status: "initiated",
      call_data_record: have_attributes(
        hangup_cause: "NORMAL_UNSPECIFIED",
        sip_invite_failure_phrase: "Temporary Unavailable",
        start_time: Time.utc(2016, 9, 20, 9, 15, 23),
        end_time: Time.utc(2016, 9, 20, 9, 15, 24),
        answer_time: nil,
        sip_term_status: "487",
        file: have_attributes(
          attached?: true
        )
      )
    )
    expect(CompletePhoneCallJob).to have_been_enqueued.with(phone_call)
    expect(account_session_limiter.session_count_for(:hydrogen, scope: account.id)).to eq(1)
    expect(global_session_limiter.session_count_for(:hydrogen)).to eq(1)
  end

  it "handles duplicates" do
    cdr = build_cdr
    account = create(:account)
    phone_call = create(
      :phone_call, :initiated, :with_status_callback_url,
      account:, id: cdr.dig("variables", "sip_rh_X-Somleng-CallSid")
    )
    account_session_limiter, global_session_limiter = build_session_limiters(account:, sessions: { hydrogen: 2 })

    2.times { ProcessCDRJob.perform_now(encode(cdr.to_json)) }

    expect(CallDataRecord.count).to eq(1)
    expect(phone_call.call_data_record).to be_present
    expect(account_session_limiter.session_count_for(:hydrogen, scope: account.id)).to eq(1)
    expect(global_session_limiter.session_count_for(:hydrogen)).to eq(1)
  end

  it "retries on missing calls" do
    cdr = build_cdr(
      variables: {
        "uuid" => SecureRandom.uuid,
        "sip_rh_X-Somleng-CallSid" => nil,
        "sip_h_X-Somleng-CallSid" => nil
      }
    )

    ProcessCDRJob.perform_now(encode(cdr.to_json))

    expect(ProcessCDRJob).to have_been_enqueued
  end

  it "handles invalid JSON" do
    cdr = file_fixture("freeswitch_cdr_with_invalid_json.json").read

    phone_call = create(:phone_call, :initiated, id: "0f8fdc31-8508-4c91-be9c-2a46cf730343")

    ProcessCDRJob.perform_now(encode(cdr))

    expect(JSON.parse(phone_call.call_data_record.file.download).dig("callStats", "audio", "inbound")).to include(
      "quality_percentage" => nil,
      "mos" => nil
    )
  end

  def build_cdr(from: "freeswitch_cdr.json", variables: {})
    cdr = JSON.parse(file_fixture(from).read)
    cdr["variables"].merge!(variables.stringify_keys)
    cdr
  end

  def encode(cdr)
    Base64.encode64(ActiveSupport::Gzip.compress(URI.encode_www_form(cdr: Base64.encode64(cdr))))
  end

  def build_session_limiters(account:, sessions: {}, **)
    session_limiters = [ AccountCallSessionLimiter.new(**), GlobalCallSessionLimiter.new(**) ]

    sessions.each do |region, count|
      session_limiters.each do |session_limiter|
        count.times { session_limiter.add_session_to(region, scope: account.id) }
      end
    end

    session_limiters
  end
end
