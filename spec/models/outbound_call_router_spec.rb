require "rails_helper"

RSpec.describe OutboundCallRouter do
  describe "#routing_instructions" do
    it "returns a dial string" do
      result = OutboundCallRouter.new("+23278910143").routing_instructions

      expect(result).to eq("dial_string" => "23278910143@197.215.105.30")
    end

    it "handles unknown source destination gateway" do
      result = OutboundCallRouter.new("+85513333333").routing_instructions

      expect(result).to eq(nil)
    end

    it "handles a gateway has prefix false" do
      result = OutboundCallRouter.new("+85516701721").routing_instructions

      expect(result).to eq("dial_string" => "016701721@27.109.112.140")
    end
  end
end
