require "rails_helper"

RSpec.describe ProcessCDR do
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
      :phone_call, :initiated, :with_status_callback_url,
      id: cdr.dig("variables", "sip_rh_X-Somleng-CallSid"),
      region: "helium", account:
    )
    account_session_limiter, global_session_limiter = build_session_limiters(account:, sessions: { helium: 2 })

    ProcessCDR.call(compress(cdr), session_limiters: [ account_session_limiter, global_session_limiter ])

    expect(phone_call.reload.status).to eq("not_answered")
    expect(phone_call.call_data_record).to have_attributes(
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
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(
      "TwilioAPI::NotifyWebhook",
      account: phone_call.account,
      url: phone_call.status_callback_url,
      http_method: phone_call.status_callback_method,
      params: hash_including("CallStatus" => "no-answer")
    )
    expect(account_session_limiter.session_count_for(:helium, scope: account.id)).to eq(1)
    expect(global_session_limiter.session_count_for(:helium)).to eq(1)
  end

  it "handles duplicates" do
    cdr = build_cdr
    phone_call = create(
      :phone_call, :initiated, :with_status_callback_url,
      id: cdr.dig("variables", "sip_rh_X-Somleng-CallSid")
    )

    2.times { ProcessCDR.call(compress(cdr)) }

    expect(CallDataRecord.count).to eq(1)
    expect(phone_call.call_data_record).to be_present
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

  def build_cdr(from: "freeswitch_cdr.json", variables: {})
    cdr = JSON.parse(file_fixture(from).read)
    cdr["variables"].merge!(variables.stringify_keys)
    cdr
  end

  def compress(cdr)
    Base64.encode64(ActiveSupport::Gzip.compress(cdr.to_json))
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
