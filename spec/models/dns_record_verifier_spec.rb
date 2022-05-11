require "rails_helper"

RSpec.describe DNSRecordVerifier do
  it "verifies a record" do
    expect(
      DNSRecordVerifier.new.verify(
        host: "example.com",
        record_value: "wgyf8z8cgvm2qmxpnbnldrcltvk4xqfn"
      )
    ).to eq(true)
  end

  it "handles invalid records" do
    expect(
      DNSRecordVerifier.new.verify(
        host: "example.com",
        record_value: "invalid"
      )
    ).to eq(false)
  end
end
