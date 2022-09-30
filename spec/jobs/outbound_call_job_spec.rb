require "rails_helper"

RSpec.describe OutboundCallJob do
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

    OutboundCallJob.perform_now(phone_call)

    expect(phone_call.external_id).to eq("123456789")
    expect(phone_call.status).to eq("initiated")
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

    OutboundCallJob.perform_now(phone_call)

    expect(WebMock).not_to have_requested(:post, "https://ahn.somleng.org/calls")
  end

  it "handles failed outbound calls" do
    phone_call = create(:phone_call, :outbound, :queued, :routable)
    stub_request(:post, "https://ahn.somleng.org/calls").to_return(status: 500)

    expect do
      OutboundCallJob.perform_now(phone_call)
    end.to raise_error(OutboundCallJob::RetryJob)

    expect(phone_call.status).to eq("initiating")
    expect(WebMock).to have_requested(:post, "https://ahn.somleng.org/calls")
  end

  it "handles max number of channels" do
    sip_trunk = create(:sip_trunk, :busy)
    phone_call = create(:phone_call, :outbound, :queued, :routable, sip_trunk:)

    travel_to(Time.current) do
      OutboundCallJob.perform_now(phone_call)

      expect(phone_call.status).to eq("queued")
      expect(ScheduledJob).to have_been_enqueued.with(
        OutboundCallJob.to_s,
        phone_call,
        wait_until: 10.seconds.from_now
      )
    end
  end

  def stub_switch_request(external_call_id: "ext-id")
    stub_request(
      :post, "https://ahn.somleng.org/calls"
    ).to_return(body: "{\"id\": \"#{external_call_id}\"}")
  end
end
