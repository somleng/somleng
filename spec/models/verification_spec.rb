require "rails_helper"

RSpec.describe Verification do
  describe ".pending" do
    it "returns pending verifications" do
      pending_verification = create(:verification, status: :pending)
      _approved_verification = create(:verification, status: :approved)
      _expired_verification = create(:verification, :expired)

      expect(Verification.pending).to contain_exactly(pending_verification)
    end
  end
end
