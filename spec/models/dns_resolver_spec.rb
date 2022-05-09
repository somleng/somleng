require "rails_helper"

RSpec.describe DNSResolver do
  it "verifies a record" do
    expect(
      DNSResolver.new.resolve?(
        host: "example.com",
        record_value: "wgyf8z8cgvm2qmxpnbnldrcltvk4xqfn"
      )
    ).to eq(true)
  end

  it "handles invalid records" do
    expect(
      DNSResolver.new.resolve?(
        host: "example.com",
        record_value: "invalid"
      )
    ).to eq(false)
  end
end
