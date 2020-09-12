require "rails_helper"

RSpec.describe OutboundCallJob do
  it "initiates an outbound call" do
    phone_call = create(
      :phone_call,
      :queued,
      to: "85516701721",
      from: "1294",
      voice_url: "http://example.com/voice_url"
    )
    stub_request(:post, "https://ahn.somleng.org/calls").to_return(body: "{\"id\": \"123456789\"}")

    OutboundCallJob.new.perform(phone_call)

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
        to: "+85516701721",
        from: "1294",
        routing_instructions: {
          dial_string: be_present
        }
      }
    )
  end

  it "handles unknown gateways" do
    phone_call = create(
      :phone_call,
      :queued,
      to: "85513333333"
    )

    OutboundCallJob.new.perform(phone_call)

    expect(phone_call.status).to eq("canceled")
  end

  it "handles failed outbound calls" do
    phone_call = create(:phone_call, :queued, to: "85516701721")
    stub_request(:post, "https://ahn.somleng.org/calls").to_return(status: 500)

    OutboundCallJob.new.perform(phone_call)

    expect(phone_call.status).to eq("canceled")
    expect(WebMock).to have_requested(:post, "https://ahn.somleng.org/calls")
  end
end
