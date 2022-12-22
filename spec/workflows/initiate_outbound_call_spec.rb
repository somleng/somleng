require "rails_helper"

RSpec.describe InitiateOutboundCall do
  it "initiates an outbound call" do
    carrier = create(:carrier)
    sip_trunk = create(
      :sip_trunk,
      outbound_symmetric_latching_supported: false,
      outbound_host: "sip.example.com",
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
    stub_switch_request(external_call_id: "123456789")

    InitiateOutboundCall.call(phone_call)

    expect(phone_call.external_id).to eq("123456789")
    expect(phone_call.status).to eq("initiated")
    expect(phone_call.initiating_at.present?).to eq(true)
    expect(phone_call.initiated_at.present?).to eq(true)

    expect(WebMock).to have_requested(:post, "https://ahn.somleng.org/calls").with(
      body: {
        sid: phone_call.id,
        account_sid: phone_call.account.id,
        account_auth_token: phone_call.account.auth_token,
        direction: "outbound-api",
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

    expect(WebMock).not_to have_requested(:post, "https://ahn.somleng.org/calls")
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
    stub_request(:post, "https://ahn.somleng.org/calls").to_return(status: 500)

    expect do
      InitiateOutboundCall.call(phone_call)
    end.to raise_error(InitiateOutboundCall::Error)

    expect(phone_call.status).to eq("initiating")
    expect(phone_call.initiating_at.present?).to eq(true)
    expect(phone_call.initiated_at).to eq(nil)
    expect(WebMock).to have_requested(:post, "https://ahn.somleng.org/calls")
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

  def stub_switch_request(external_call_id: SecureRandom.uuid)
    responses = Array(external_call_id).map { |id| { body: { id: }.to_json } }
    stub_request(:post, "https://ahn.somleng.org/calls").to_return(responses)
  end
end
