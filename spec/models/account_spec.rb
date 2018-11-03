require "rails_helper"

describe Account do
  describe "state_machine" do
    it "transitions from enabled to disabled" do
      account = build_stubbed(:account, :enabled)

      account.disable

      expect(account).to be_disabled
    end

    it "transitions from disabled to enabled" do
      account = build_stubbed(:account, :enabled)

      account.disable

      expect(account).to be_disabled
    end
  end
end
