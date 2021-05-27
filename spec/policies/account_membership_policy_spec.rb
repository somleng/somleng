require "rails_helper"

RSpec.describe AccountMembershipPolicy do
  it "does not authorize destroy for memberships with unaccepted invitations" do
    user = build_stubbed(:user, :carrier, :admin, :invitation_accepted)
    membership = build_stubbed(:account_membership, user: user)

    policy = AccountMembershipPolicy.new(user, membership)

    expect(policy.destroy?).to eq(false)
  end
end
