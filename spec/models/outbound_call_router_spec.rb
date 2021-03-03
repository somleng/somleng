require "rails_helper"

RSpec.describe OutboundCallRouter do
  describe "#routing_instructions" do
    it "returns a dial string" do
      result = OutboundCallRouter.new("23278910143").routing_instructions

      expect(result).to eq("dial_string" => "23278910143@197.215.105.30")
    end

    it "handles unknown source destination gateway" do
      expect {
        OutboundCallRouter.new("85513333333").routing_instructions
      }.to raise_error(OutboundCallRouter::UnsupportedGatewayError)
    end

    it "handles a gateway has prefix false" do
      result = OutboundCallRouter.new("85516701721").routing_instructions

      expect(result).to eq("dial_string" => "016701721@27.109.112.140")
    end

    it "handles dial string prefixes" do
      result = OutboundCallRouter.new("525551478040").routing_instructions

      expect(result).to eq("dial_string" => "69980525551478040@200.0.90.35")
    end
  end
end
