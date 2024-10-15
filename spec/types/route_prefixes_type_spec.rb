require "rails_helper"

RSpec.describe RoutePrefixesType do
  it "handles route prefixes" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :route_prefixes, RoutePrefixesType.new
    end

    expect(klass.new(route_prefixes: []).route_prefixes).to eq([])
    expect(klass.new(route_prefixes: [ "088", "097" ]).route_prefixes).to eq([ "088", "097" ])
    expect(klass.new(route_prefixes: "").route_prefixes).to eq([])
    expect(klass.new(route_prefixes: "088, 097, 097, abc, ").route_prefixes).to eq([ "088", "097" ])
  end
end
