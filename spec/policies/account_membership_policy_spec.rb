require "rails_helper"

RSpec.describe AccountMembershipPolicy, type: :policy do
  it "denies access to users managing their own membership" do
    account_membership = create(:account_membership, :owner)
    user_context = build_user_context_for_account(role: :owner, account_membership: account_membership)

    policy = AccountMembershipPolicy.new(user_context, account_membership)

    expect(policy.update?).to eq(false)
    expect(policy.destroy?).to eq(false)
  end

  it "grants access to account owners" do
    account_membership = create(:account_membership, :owner)
    user_context = build_user_context_for_account(account_membership: account_membership)
    managed_account_membership = create(:account_membership, account: account_membership.account)

    policy = AccountMembershipPolicy.new(user_context, managed_account_membership)

    expect(policy.update?).to eq(true)
    expect(policy.destroy?).to eq(true)
  end

  it "denies access to account admins" do
    user_context = build_user_context_for_account(role: :admin)

    policy = AccountMembershipPolicy.new(user_context)

    expect(policy.index?).to eq(false)
    expect(policy.create?).to eq(false)
  end
end
