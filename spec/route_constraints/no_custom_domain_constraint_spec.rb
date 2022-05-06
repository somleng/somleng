require "rails_helper"

RSpec.describe NoCustomDomainConstraint do
  it "handles normal domains" do
    constraint = NoCustomDomainConstraint.new
    request = stub_request(
      "HTTP_HOST" => "dashboard.somleng.org"
    )

    result = constraint.matches?(request)

    expect(result).to eq(true)
  end

  it "rejects custom domains" do
    constraint = NoCustomDomainConstraint.new
    request = stub_request(
      "HTTP_HOST" => "dashboard.somleng.org",
      "HTTP_X_FORWARDED_HOST" => "xyz.example.com"
    )

    result = constraint.matches?(request)

    expect(result).to eq(false)
  end

  def stub_request(headers)
    ActionDispatch::TestRequest.create(headers)
  end
end
