require "rails_helper"

RSpec.describe CheckVerificationCode do
  it "creates a verification attempt" do
    verification = create(:verification, code: "1234", status: :pending)

    CheckVerificationCode.call(verification:, code: "9876")

    expect(verification).to have_attributes(
      verification_attempts_count: 1,
      status: "pending",
      verification_attempts: be_present
    )
  end

  it "approves the verification" do
    verification = create(:verification, status: :pending)

    CheckVerificationCode.call(verification:, code: verification.code)

    expect(verification.status).to eq("approved")
  end
end
