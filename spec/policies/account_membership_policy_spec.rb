require "rails_helper"

RSpec.describe AccountMembershipPolicy do
  describe "#destroy?" do
    it "denies access to carrier owners for memberships with an accepted invitation" do
      carrier = build_stubbed(:carrier)
      user_context = build_user_context_for_carrier(role: :owner)
      user = build_stubbed(:user, :invitation_accepted)
      account = build_stubbed(:account, carrier: carrier)
      account_membership = build_stubbed(:account_membership, account: account, user: user)

      policy = AccountMembershipPolicy.new(user_context, account_membership)

      expect(policy.destroy?).to eq(false)
    end

    it "allows access to carrier owners for memberships with an pending invitations" do
      carrier = build_stubbed(:carrier)
      user_context = build_user_context_for_carrier(role: :owner)
      user = build_stubbed(:user, :invited)
      account = build_stubbed(:account, carrier: carrier)
      account_membership = build_stubbed(:account_membership, account: account, user: user)

      policy = AccountMembershipPolicy.new(user_context, account_membership)

      expect(policy.destroy?).to eq(true)
    end
  end

  describe "#manage?" do
    it "allows carrier admins"
  end

  describe "#update?" do
    it "denies access to carrier owners" do
      carrier = build_stubbed(:carrier)
      user_context = build_user_context_for_carrier(carrier: carrier, role: :owner)
      account = build_stubbed(:account, carrier: carrier)
      account_membership = build_stubbed(:account_membership, account: account)

      policy = AccountMembershipPolicy.new(user_context, account_membership)

      expect(policy.update?).to eq(false)
    end

    it "grants access to account owners" do
      user_context = build_user_context_for_account(role: :owner)
      account_membership = build_stubbed(:account_membership, account: user_context.current_account_membership.account)

      policy = AccountMembershipPolicy.new(user_context, account_membership)

      expect(policy.update?).to eq(true)
    end

    it "denies access to account admins" do
      user_context = build_user_context_for_account(role: :admin)
      account_membership = build_stubbed(:account_membership, account: user_context.current_account_membership.account)

      policy = AccountMembershipPolicy.new(user_context, account_membership)

      expect(policy.update?).to eq(false)
    end
  end

  def build_user_context_for_carrier(role:, carrier: nil)
    carrier ||= build_stubbed(:carrier)
    user = build_stubbed(:user, :carrier, role, carrier: carrier)
    organization = build_stubbed(:dashboard_organization, organization: carrier)
    build_stubbed(:user_context, user: user, current_organization: organization)
  end

  def build_user_context_for_account(role:, account: nil)
    account ||= build_stubbed(:account)
    user = build_stubbed(:user)
    account_membership = build_stubbed(:account_membership, role, user: user, account: account)
    organization = build_stubbed(:dashboard_organization, organization: account)
    build_stubbed(
      :user_context,
      user: user,
      current_organization: organization,
      current_account_membership: account_membership
    )
  end
end
