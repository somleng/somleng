require "rails_helper"

RSpec.describe VerifyCustomDomain do
  it "verifies a domain" do
    custom_domain = create(:custom_domain)
    domain_verifier = instance_double(DNSRecordVerifier, verify: true)

    result = VerifyCustomDomain.call(custom_domain, domain_verifier:)

    expect(result).to eq(true)
    expect(custom_domain.verified?).to eq(true)
  end

  it "handles invalid domains" do
    custom_domain = create(:custom_domain, host: "example.com")

    result = VerifyCustomDomain.call(custom_domain)

    expect(result).to be_falsey
    expect(custom_domain.verified?).to eq(false)
  end

  it "handles already verified domains" do
    custom_domain = create(:custom_domain, :verified)

    result = VerifyCustomDomain.call(custom_domain)

    expect(result).to eq(true)
    expect(custom_domain.verified?).to eq(true)
  end

  it "handles duplicate hosts" do
    existing_custom_domain = create(:custom_domain, :verified)
    custom_domain = create(:custom_domain, host: existing_custom_domain.host)

    result = VerifyCustomDomain.call(custom_domain)

    expect(result).to eq(false)
    expect(custom_domain.verified?).to eq(false)
  end
end
