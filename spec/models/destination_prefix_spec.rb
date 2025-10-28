require "rails_helper"

RSpec.describe DestinationPrefix do
  describe ".longest_match_for" do
    it "returns the longest prefix" do
      smart_cambodia = create(:destination_prefix, prefix: "85510")
      cambodia = create(:destination_prefix, prefix: "855")
      laos = create(:destination_prefix, prefix: "856")

      expect(
        DestinationPrefix.longest_match_for("85510345678")
      ).to eq(smart_cambodia)

      expect(
        DestinationPrefix.longest_match_for("85512345678")
      ).to eq(cambodia)

      expect(
        DestinationPrefix.longest_match_for("85612345678")
      ).to eq(laos)
    end
  end
end
