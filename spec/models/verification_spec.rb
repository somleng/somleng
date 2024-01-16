require "rails_helper"

RSpec.describe Verification do
  describe ".pending" do
    it "returns pending verifications" do
      pending_verification = create(:verification, :pending)
      _approved_verification = create(:verification, :approved)
      _expired_verification = create(:verification, :expired)

      expect(Verification.pending).to contain_exactly(pending_verification)
    end
  end

  describe ".expired" do
    it "returns expired verifications" do
      _pending_verification = create(:verification, :pending)
      _approved_verification = create(:verification, :approved)
      expired_verification = create(:verification, :expired)

      expect(Verification.expired).to contain_exactly(expired_verification)
    end
  end
end
