require "rails_helper"

RSpec.describe IPAddressArrayType do
  it "handles IP address arrays" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :ips, IPAddressArrayType.new
    end

    expect(klass.new(ips: nil).ips).to eq([])
    expect(klass.new(ips: []).ips).to eq([])
    expect(klass.new(ips: [ IPAddr.new("127.0.0.1") ]).ips).to eq([ IPAddr.new("127.0.0.1") ])
    expect(klass.new(ips: [ "127.0.0.1", "127.0.0.1" ]).ips).to eq([ "127.0.0.1" ])
    expect(klass.new(ips: [ "89.0.142.86", "89.0.142.256" ]).ips).to eq([ "89.0.142.86" ])
  end
end
