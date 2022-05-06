require "rails_helper"

RSpec.describe HostnameType do
  it "handles hostnames" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :hostname, HostnameType.new
    end

    expect(klass.new(hostname: nil).hostname).to eq(nil)
    expect(klass.new(hostname: "foo").hostname).to eq("foo")
    expect(klass.new(hostname: "foobar.com").hostname).to eq("foobar.com")
    expect(klass.new(hostname: "https://foobar.com").hostname).to eq("foobar.com")
    expect(klass.new(hostname: "https://foobar.com:5003").hostname).to eq("foobar.com")
  end
end
