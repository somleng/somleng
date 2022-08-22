require "rails_helper"

RSpec.describe OutboundCallJob do
  it "initiates an outbound call" do
    carrier = create(:carrier)
    outbound_sip_trunk = create(:outbound_sip_trunk, nat_supported: false, carrier:)

    phone_call = create(
      :phone_call,
      :outbound,
      :queued,
      :routable,
      carrier:,
      outbound_sip_trunk:,
      to: "85516701721",
      dial_string: "85516701721@sip.example.com",
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
        routing_instructions: {
          dial_string: "85516701721@sip.example.com",
          nat_supported: false
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

  def stub_switch_request(external_call_id: "ext-id")
    stub_request(
      :post, "https://ahn.somleng.org/calls"
    ).to_return(body: "{\"id\": \"#{external_call_id}\"}")
  end
end
