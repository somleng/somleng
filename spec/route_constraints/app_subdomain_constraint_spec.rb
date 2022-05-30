require "rails_helper"

RSpec.describe AppSubdomainConstraint do
  it "handles handles app subdomains" do
    create(:carrier, subdomain: "foobar")
    constraint = AppSubdomainConstraint.new
    request = stub_request(
      "HTTP_HOST" => "foobar.app.somleng.org"
    )

    result = constraint.matches?(request)

    expect(result).to be(true)
  end

  it "rejects other subdomains" do
    create(:carrier, subdomain: "foobar")
    constraint = AppSubdomainConstraint.new
    request = stub_request(
      "HTTP_HOST" => "foobar.baz.somleng.org"
    )

    result = constraint.matches?(request)

    expect(result).to eq(false)
  end

  def stub_request(headers)
    ActionDispatch::TestRequest.create(headers)
  end
end
