require "rails_helper"

RSpec.describe InitiateOutboundCall do
  it "initiates an outbound call" do
    carrier = create(:carrier)
    account = create(:account, :billing_enabled, carrier:)
    sip_trunk = create(
      :sip_trunk,
      sip_profile: "test",
      outbound_host: "sip.example.com",
      region: :helium,
      carrier:
    )

    phone_call = create(
      :phone_call,
      :outbound,
      :queued,
      :routable,
      carrier:,
      account:,
      sip_trunk:,
      region: sip_trunk.region,
      to: "85516701721",
      from: "1294",
      caller_id: "1294",
      voice_url: "http://example.com/voice_url",
      voice_method: "POST",
    )
    stub_switch_request(region: :helium, external_call_id: "123456789", host: "10.10.1.13")
    account_session_limiter, global_session_limiter = build_session_limiters(account: phone_call.account)

    InitiateOutboundCall.call(phone_call:, session_limiters: [ account_session_limiter, global_session_limiter ])

    expect(phone_call).to have_attributes(
      external_id: "123456789",
      status: "initiated",
      initiating_at: be_present,
      initiated_at: be_present,
      call_service_host: have_attributes(
        to_s: "10.10.1.13"
      )
    )
    expect(WebMock).to have_requested(:post, "https://switch.helium.somleng.org/calls").with(
      body: {
        sid: phone_call.id,
        carrier_sid: carrier.id,
        account_sid: phone_call.account.id,
        account_auth_token: phone_call.account.auth_token,
        direction: "outbound-api",
        default_tts_voice: "Basic.Kal",
        api_version: "2010-04-01",
        voice_url: "http://example.com/voice_url",
        voice_method: "POST",
        twiml: nil,
        to: "+85516701721",
        from: "1294",
        routing_parameters: {
          destination: "85516701721",
          dial_string_prefix: nil,
          plus_prefix: false,
          national_dialing: false,
          host: "sip.example.com",
          username: nil,
          sip_profile: "test"
        },
        billing_parameters: {
          enabled: true,
          billing_mode: "prepaid",
          category: "outbound_calls"
        }
      }
    )
    expect(account_session_limiter.session_count_for(:helium, scope: phone_call.account_id)).to eq(1)
    expect(global_session_limiter.session_count_for(:helium)).to eq(1)
  end

  it "handles already canceled calls" do
    carrier = create(:carrier)
    sip_trunk = create(
      :sip_trunk,
      region: :hydrogen,
      carrier:
    )
    phone_call = create(:phone_call, :outbound, :routable,  :canceled, sip_trunk:, carrier:, external_id: nil, region: sip_trunk.region)

    InitiateOutboundCall.call(phone_call:)

    expect(WebMock).not_to have_requested(:post, "https://switch.hydrogen.somleng.org/calls")
  end

  it "handles deleted SIP trunks" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    sip_trunk = create(:sip_trunk, carrier:)
    phone_call = create(:phone_call, :outbound, :queued, sip_trunk:, carrier:, account:)
    sip_trunk.destroy!

    InitiateOutboundCall.call(phone_call: phone_call.reload)

    expect(phone_call.canceled?).to be(true)
  end

  it "handles failed outbound calls" do
    phone_call = create(:phone_call, :outbound, :queued, :routable, region: :hydrogen)
    stub_request(:post, "https://switch.hydrogen.somleng.org/calls").to_return(status: 500)
    account_session_limiter, global_session_limiter = build_session_limiters(account: phone_call.account, sessions: { hydrogen: 1 })

    expect do
      InitiateOutboundCall.call(phone_call:, session_limiters: [ account_session_limiter, global_session_limiter ])
    end.to raise_error(InitiateOutboundCall::Error)

    expect(phone_call.status).to eq("initiating")
    expect(phone_call.initiating_at.present?).to be(true)
    expect(phone_call.initiated_at).to be_nil
    expect(account_session_limiter.session_count_for(:hydrogen, scope: phone_call.account_id)).to eq(1)
    expect(global_session_limiter.session_count_for(:hydrogen)).to eq(1)
    expect(WebMock).to have_requested(:post, "https://switch.hydrogen.somleng.org/calls")
  end

  it "handles session limits" do
    account = create(:account)
    phone_call = create(:phone_call, :queued, account:, region: "hydrogen")
    account_session_limiter, global_session_limiter = build_session_limiters(account:, sessions: { hydrogen: 1 }, limit: 1)

    travel_to(Time.current) do
      InitiateOutboundCall.call(phone_call:, session_limiters: [ account_session_limiter, global_session_limiter ])

      expect(phone_call.status).to eq("queued")
      expect(ExecuteWorkflowJob).to have_been_enqueued.with(
        InitiateOutboundCall.to_s,
        phone_call:,
      ).at(10.seconds.from_now).on_queue(AppSettings.fetch(:aws_sqs_high_priority_queue_name))
    end
  end

  it "handles max number of channels" do
    sip_trunk = create(:sip_trunk, :busy)
    phone_call = create(:phone_call, :outbound, :queued, :routable, sip_trunk:)

    travel_to(Time.current) do
      InitiateOutboundCall.call(phone_call:)

      expect(phone_call.status).to eq("queued")
      expect(ExecuteWorkflowJob).to have_been_enqueued.with(
        InitiateOutboundCall.to_s,
        phone_call:,
      ).at(10.seconds.from_now).on_queue(AppSettings.fetch(:aws_sqs_high_priority_queue_name))
    end
  end

  it "handles channel allocation race conditions" do
    sip_trunk = create(:sip_trunk, max_channels: 1)
    phone_calls = create_list(:phone_call, 2, :outbound, sip_trunk:)
    phone_calls << create(:phone_call, :outbound)
    stub_switch_request(external_call_id: phone_calls.map { SecureRandom.uuid })

    threads = phone_calls.each_with_object([]) do |phone_call, result|
      result << Thread.new do
        InitiateOutboundCall.call(phone_call:)
      end
    end

    threads.each(&:join)

    phone_calls.each(&:reload)
    expect(phone_calls.first(2).pluck(:status)).to match_array(%w[initiated queued])
    expect(phone_calls.last.status).to eq("initiated")
  end

  def stub_switch_request(region: :hydrogen, external_call_id: SecureRandom.uuid, **response_params)
    response_params[:host] ||= "10.10.1.13"
    responses = Array(external_call_id).map { |id| { body: { id:, **response_params }.to_json } }
    stub_request(:post, "https://switch.#{region}.somleng.org/calls").to_return(responses)
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
