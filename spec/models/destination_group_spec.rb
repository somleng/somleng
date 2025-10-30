require "rails_helper"

RSpec.describe do
  describe ".catch_all" do
    it "returns catch all destination groups" do
      catch_alls = [
        create(:destination_group, prefixes: (0..9).to_a),
        create(:destination_group, prefixes: (0..9).to_a.reverse)
      ]
      create(:destination_group, prefixes: (0..8).to_a)
      create(:destination_group, prefixes: (0..10).to_a)
      create(:destination_group, prefixes: (0..8).to_a << 91)

      expect(DestinationGroup.catch_all).to match_array(catch_alls)
    end
  end
end
