require "rails_helper"

RSpec.describe SESEmailIdentityVerifier do
  it "verifies a record" do
    client = build_stubbed_client(verified_for_sending_status: true)
    verifier = SESEmailIdentityVerifier.new(host: "example.com", client:)

    expect(verifier.verify).to eq(true)
  end

  it "handles unverified records" do
    client = build_stubbed_client(verified_for_sending_status: false)
    verifier = SESEmailIdentityVerifier.new(host: "example.com", client:)

    expect(verifier.verify).to eq(false)
  end

  def build_stubbed_client(verified_for_sending_status:)
    client = Aws::SESV2::Client.new
    stubbed_response = client.stub_data(:get_email_identity)
    stubbed_response.verified_for_sending_status = verified_for_sending_status
    client.stub_responses(:get_email_identity, stubbed_response)
    client
  end
end
