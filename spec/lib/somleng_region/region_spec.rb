require "rails_helper"

module SomlengRegion
  RSpec.describe Region do
    describe "#to_s" do
      it "returns the region alias" do
        expect(Region.new(alias: "hydrogen").to_s).to eq("hydrogen")
      end
    end

    describe "==(other)" do
      it "handles equality" do
        expect(Region.new(alias: "hydrogen")).to eq(Region.new(alias: "hydrogen"))
        expect(Region.new(alias: "hydrogen")).to eq("hydrogen")
        expect(Region.new(alias: "hydrogen")).not_to eq(Region.new(alias: "helium"))
        expect(Region.new(alias: "helium")).not_to eq("hydrogen")
      end
    end
  end
end
