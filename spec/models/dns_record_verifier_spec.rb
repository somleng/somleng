require "rails_helper"

RSpec.describe DNSRecordVerifier do
  it "verifies a record" do
    verifier = DNSRecordVerifier.new(
      host: "example.com",
      record_value: "wgyf8z8cgvm2qmxpnbnldrcltvk4xqfn"
    )

    expect(verifier.verify).to eq(true)
  end

  it "handles invalid records" do
    verifier = DNSRecordVerifier.new(
      host: "example.com",
      record_value: "invalid"
    )

    expect(verifier.verify).to eq(false)
  end
end
