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
    domain_verifier = build_domain_verifier(custom_domain)

    result = VerifyCustomDomain.call(custom_domain, domain_verifier:)

    expect(result).to be_falsey
    expect(custom_domain.verified?).to eq(false)
  end

  it "handles already verified domains" do
    custom_domain = create(:custom_domain, :verified)
    domain_verifier = build_domain_verifier(custom_domain)

    result = VerifyCustomDomain.call(custom_domain, domain_verifier:)

    expect(result).to eq(true)
    expect(custom_domain.verified?).to eq(true)
  end

  it "handles duplicate hosts" do
    existing_custom_domain = create(:custom_domain, :verified)
    custom_domain = create(:custom_domain, host: existing_custom_domain.host)
    domain_verifier = build_domain_verifier(custom_domain)

    result = VerifyCustomDomain.call(custom_domain, domain_verifier:)

    expect(result).to eq(false)
    expect(custom_domain.verified?).to eq(false)
  end

  def build_domain_verifier(custom_domain)
    DNSRecordVerifier.new(host: custom_domain.host, record_value: custom_domain.verification_token)
  end
end
