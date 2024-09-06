require "rails_helper"

RSpec.describe InitiateOutboundCall do
  it "initiates an outbound call" do
    carrier = create(:carrier)
    sip_trunk = create(
      :sip_trunk,
      outbound_symmetric_latching_supported: false,
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
      sip_trunk:,
      to: "85516701721",
      from: "1294",
      caller_id: "1294",
      voice_url: "http://example.com/voice_url",
      voice_method: "POST"
    )
    stub_switch_request(region: :helium, external_call_id: "123456789", host: "10.10.1.13")

    InitiateOutboundCall.call(phone_call)

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
          symmetric_latching: false
        }
      }
    )
  end

  it "handles already canceled calls" do
    phone_call = create(:phone_call, :outbound, :routable, :canceled, external_id: nil)

    InitiateOutboundCall.call(phone_call)

    expect(WebMock).not_to have_requested(:post, "https://switch.internal.somleng.org/calls")
  end

  it "handles deleted SIP trunks" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    sip_trunk = create(:sip_trunk, carrier:)
    phone_call = create(:phone_call, :outbound, :queued, sip_trunk:, carrier:, account:)
    sip_trunk.destroy!

    InitiateOutboundCall.call(phone_call.reload)

    expect(phone_call.canceled?).to eq(true)
  end

  it "handles failed outbound calls" do
    phone_call = create(:phone_call, :outbound, :queued, :routable)
    stub_request(:post, "https://switch.hydrogen.somleng.org/calls").to_return(status: 500)

    expect do
      InitiateOutboundCall.call(phone_call)
    end.to raise_error(InitiateOutboundCall::Error)

    expect(phone_call.status).to eq("initiating")
    expect(phone_call.initiating_at.present?).to eq(true)
    expect(phone_call.initiated_at).to eq(nil)
    expect(WebMock).to have_requested(:post, "https://switch.hydrogen.somleng.org/calls")
  end

  it "handles max number of channels" do
    sip_trunk = create(:sip_trunk, :busy)
    phone_call = create(:phone_call, :outbound, :queued, :routable, sip_trunk:)

    travel_to(Time.current) do
      InitiateOutboundCall.call(phone_call)

      expect(phone_call.status).to eq("queued")
      expect(ScheduledJob).to have_been_enqueued.with(
        OutboundCallJob.to_s,
        phone_call,
        wait_until: 10.seconds.from_now
      )
    end
  end

  it "handles channel allocation race conditions" do
    sip_trunk = create(:sip_trunk, max_channels: 1)
    phone_calls = create_list(:phone_call, 2, :outbound, sip_trunk:)
    phone_calls << create(:phone_call, :outbound)
    stub_switch_request(external_call_id: phone_calls.map { SecureRandom.uuid })

    threads = phone_calls.each_with_object([]) do |phone_call, result|
      result << Thread.new do
        InitiateOutboundCall.call(phone_call)
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
end
