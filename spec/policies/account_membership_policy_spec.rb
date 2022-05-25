require "rails_helper"

RSpec.describe AccountMembershipPolicy, type: :policy do
  it "denies access to users managing their own membership" do
    account_membership = build_stubbed(:account_membership, :owner)

    policy = AccountMembershipPolicy.new(account_membership.user, account_membership)

    expect(policy.update?).to eq(false)
    expect(policy.destroy?).to eq(false)
  end

  it "grants access to account owners" do
    account_membership = create(:account_membership, :owner)
    managed_account_membership = create(:account_membership, account: account_membership.account)

    policy = AccountMembershipPolicy.new(account_membership.user, managed_account_membership)

    expect(policy.update?).to eq(true)
    expect(policy.destroy?).to eq(true)
  end

  it "denies access to account admins" do
    account_membership = build_stubbed(:account_membership, :admin)

    policy = AccountMembershipPolicy.new(account_membership.user)

    expect(policy.index?).to eq(true)
    expect(policy.create?).to eq(false)
  end
end
