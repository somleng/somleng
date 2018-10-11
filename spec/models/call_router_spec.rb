require "spec_helper"

describe CallRouter do
  describe "#normalized_source" do
    it "returns the normalized source" do
      call_router = described_class.new(source: "+0972345678")

      call_router.trunk_prefix_replacement = "855"
      expect(call_router.normalized_source).to eq("+855972345678")

      call_router.trunk_prefix_replacement = "856"
      expect(call_router.normalized_source).to eq("+856972345678")

      call_router.trunk_prefix = "1"
      expect(call_router.normalized_source).to eq("+0972345678")

      call_router.trunk_prefix_replacement = nil
      expect(call_router.normalized_source).to eq("+0972345678")

      call_router = described_class.new(trunk_prefix_replacement: "855")

      call_router.source = "+855972345678"
      expect(call_router.normalized_source).to eq("+855972345678")

      call_router.source = "855972345678"
      expect(call_router.normalized_source).to eq("855972345678")

      call_router.source = "10972345678"
      expect(call_router.normalized_source).to eq("10972345678")
    end
  end

  describe "#routing_instructions" do
    it "returns routing instructions" do
      call_router = described_class.new(
        source: "8551294",
        source_matcher: /(\d{4}$)/
      )

      # Cambodia (Smart)
      call_router.destination = "+85510344566"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "1294",
        destination: "85510344566",
        dial_string_path: "external/010344566@27.109.112.80"
      )

      # Cambodia (Cellcard)
      call_router.destination = "+85512345677"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "1294",
        destination: "85512345677",
        dial_string_path: "external/012345677@103.193.204.17"
      )

      # Cambodia (Metfone)
      call_router.destination = "+855882345678"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "1294",
        destination: "855882345678",
        dial_string_path: "external/0882345678@175.100.32.29"
      )

      # Cambodia (Metfone 1296)
      call_router.source = "+85512001296"
      call_router.destination = "+855882345678"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "095975802",
        destination: "855882345678",
        dial_string_path: "external/0882345678@103.193.204.17"
      )

      # Unknown source

      call_router.source = "5555"
      call_router.destination = "+855882345678"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "5555",
        destination: "855882345678",
        dial_string_path: "external/0882345678@175.100.32.29"
      )

      # Unknown destination

      call_router.destination = "+85688234567"

      result = call_router.routing_instructions

      expect(result.fetch("disable_originate")).to eq("1")

      # Sierra Leone (Africell)

      call_router.source = "5555"
      call_router.destination = "+23230234567"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "5555",
        destination: "23230234567",
        dial_string_path: "external/23230234567@freeswitch-private.internal.unicef.io"
      )

      # Somalia (Telesom)
      call_router.destination = "+252634000613"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "5555",
        destination: "252634000613",
        dial_string_path: "external/252634000613@196.201.207.191"
      )

      # Somalia (Golis)
      call_router.destination = "+252902345678"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "5555",
        destination: "252902345678",
        dial_string_path: "external/252902345678@196.201.207.191"
      )

      # Somalia (NationLink)
      call_router.destination = "+252692345678"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "5555",
        destination: "252692345678",
        dial_string_path: "external/252692345678@196.201.207.191"
      )

      # Somalia (Somtel)
      call_router.destination = "+252652345678"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "5555",
        destination: "252652345678",
        dial_string_path: "external/252652345678@196.201.207.191"
      )

      # Somalia (Hormuud)
      call_router.destination = "+252642345678"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "5555",
        destination: "252642345678",
        dial_string_path: "external/252642345678@196.201.207.191"
      )

      # Brazil (Mundivox)
      call_router.destination = "+5582999489999"

      result = call_router.routing_instructions

      assert_routing_instructions!(
        result,
        source: "5555",
        destination: "5582999489999",
        dial_string_path: "external/5582999489999@187.102.153.186"
      )
    end
  end

  def assert_routing_instructions!(result, source:, destination:, dial_string_path:)
    expect(result.fetch("source")).to eq(source)
    expect(result.fetch("destination")).to eq(destination)
    expect(result.fetch("dial_string_path")).to eq(dial_string_path)
  end
end
