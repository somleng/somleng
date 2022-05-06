require "rails_helper"

RSpec.describe CustomDomainSubdomainConstraint do
  it "handles normal hosts" do
    constraint = CustomDomainSubdomainConstraint.new(
      host: "api.somleng.org"
    )
    request = stub_request(
      "HTTP_HOST" => "api.somleng.org"
    )

    result = constraint.matches?(request)

    expect(result).to eq(true)
  end

  it "handles hosts with port" do
    constraint = CustomDomainSubdomainConstraint.new(
      host: "api.somleng.org"
    )
    request = stub_request(
      "HTTP_HOST" => "api.somleng.org:56186"
    )

    result = constraint.matches?(request)

    expect(result).to eq(true)
  end

  it "handles custom domains" do
    constraint = CustomDomainSubdomainConstraint.new(
      host: "api.somleng.org"
    )
    request = stub_request(
      "HTTP_HOST" => "api.somleng.org",
      "HTTP_X_FORWARDED_HOST" => "xyz.example.com"
    )

    result = constraint.matches?(request)

    expect(result).to eq(true)
  end

  it "rejects invalid subdomains" do
    constraint = CustomDomainSubdomainConstraint.new(
      host: "api.somleng.org"
    )
    request = stub_request(
      "HTTP_HOST" => "foobar.somleng.org",
      "HTTP_X_FORWARDED_HOST" => "api.example.com"
    )

    result = constraint.matches?(request)

    expect(result).to eq(false)
  end

  it "handles multi-level hosts" do
    constraint = CustomDomainSubdomainConstraint.new(
      host: "custom-api.product-name.telco.com"
    )
    request = stub_request(
      "HTTP_HOST" => "custom-api.product-name.telco.com"
    )

    result = constraint.matches?(request)

    expect(result).to eq(true)
  end

  def stub_request(headers)
    ActionDispatch::TestRequest.create(headers)
  end
end
