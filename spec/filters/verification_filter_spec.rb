require "rails_helper"

RSpec.describe VerificationFilter do
  it "filters by status" do
    pending_verification = create(:verification, :pending)
    expired_verification = create(:verification, :expired)
    approved_verification = create(:verification, :approved)
    canceled_verification = create(:verification, :canceled)

    expect(build_filter(status: "pending").apply).to contain_exactly(pending_verification)
    expect(build_filter(status: "expired").apply).to contain_exactly(expired_verification)
    expect(build_filter(status: "approved").apply).to contain_exactly(approved_verification)
    expect(build_filter(status: "canceled").apply).to contain_exactly(canceled_verification)
  end

  it "filters by verification service" do
    verification = create(:verification)
    _other_verification = create(:verification)

    expect(
      build_filter(verification_service_id: verification.verification_service_id).apply
    ).to contain_exactly(verification)
  end

  def build_filter(filter_params)
    VerificationFilter.new(
      resources_scope: Verification,
      input_params: {
        filter: filter_params
      }
    )
  end
end
