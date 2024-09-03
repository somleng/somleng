require "rails_helper"

RSpec.describe RegionType do
  it "handles regions" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :region, RegionType.new
    end

    expect(klass.new(region: nil).region).to eq(nil)
    expect(klass.new(region: "foo").region).to eq(nil)
    expect(klass.new(region: "hydrogen").region).to be_a(SomlengRegions::Region)
  end
end
