require "rails_helper"

RSpec.describe CreateEmailIdentity do
  it "creates an email identity" do
    custom_domain = create(:custom_domain, :mail, host: "example.com")
    tokens = %w[token-1 token-2 token-3]
    client = build_stubbed_client(tokens:)

    CreateEmailIdentity.call(custom_domain, client:)

    expect(custom_domain.verification_data.fetch("dkim_tokens")).to eq(tokens)
    request = client.api_requests.first
    expect(request).to match(
      hash_including(
        operation_name: :create_email_identity,
        params: hash_including(
          email_identity: "example.com",
          tags: [{ key: "ManagedBy", value: "somleng" }]
        )
      )
    )
  end

  def build_stubbed_client(tokens: [])
    client = Aws::SESV2::Client.new(stub_responses: true)
    stubbed_response = client.stub_data(:create_email_identity)
    stubbed_response.dkim_attributes.tokens = tokens
    client.stub_responses(:create_email_identity, stubbed_response)
    client
  end
end
