require "rails_helper"

RSpec.describe TwoFactorAuthenticationPolicy, type: :policy do
  describe "#new?" do
    it "allows access" do
      user_context = build_stubbed(:user_context)
      policy = TwoFactorAuthenticationPolicy.new(user_context, nil)

      expect(policy.new?).to eq(true)
    end
  end

  describe "#destroy?" do
    it "denies access to reset 2FA for oneself" do
      user_context = build_user_context_for_carrier(
        carrier_role: :owner,
        otp_required_for_login: true
      )

      policy = TwoFactorAuthenticationPolicy.new(user_context, user_context)

      expect(policy.destroy?).to eq(false)
    end

    it "denies access for carrier admins" do
      user_context = build_user_context_for_carrier(carrier_role: :admin)
      carrier_user = create(:user, :otp_required_for_login, carrier: user_context.carrier)

      policy = TwoFactorAuthenticationPolicy.new(user_context, carrier_user)

      expect(policy.destroy?).to be_falsey
    end

    it "denies access for users outside of carrier" do
      user_context = build_user_context_for_carrier
      carrier_user = create(:user, :carrier, :otp_required_for_login)

      policy = TwoFactorAuthenticationPolicy.new(user_context, carrier_user)

      expect(policy.destroy?).to eq(false)
    end

    it "denies access for users whos 2FA is already disabled" do
      user_context = build_user_context_for_carrier
      carrier_user = create(:user, otp_required_for_login: false, carrier: user_context.carrier)

      policy = TwoFactorAuthenticationPolicy.new(user_context, carrier_user)

      expect(policy.destroy?).to eq(false)
    end

    it "allows access for carrier owners" do
      user_context = build_user_context_for_carrier
      carrier_user = create(:user, :otp_required_for_login, carrier: user_context.carrier)

      policy = TwoFactorAuthenticationPolicy.new(user_context, carrier_user)

      expect(policy.destroy?).to eq(true)
    end

    it "allows access access to account owners" do
      account = create(:account)
      account_user = create(:user, :otp_required_for_login)
      create(:account_membership, user: account_user, account: account)
      user_context = build_user_context_for_account(role: :owner, account: account)

      policy = TwoFactorAuthenticationPolicy.new(user_context, account_user)

      expect(policy.destroy?).to eq(true)
    end

    it "denies access access to account admins" do
      account = create(:account)
      account_user = create(:user, :otp_required_for_login)
      create(:account_membership, user: account_user, account: account)
      user_context = build_user_context_for_account(role: :admin, account: account)

      policy = TwoFactorAuthenticationPolicy.new(user_context, account_user)

      expect(policy.destroy?).to be_falsey
    end

    it "denies access to users outside of account" do
      account = create(:account)
      account_user = create(:user, :otp_required_for_login)
      user_context = build_user_context_for_account(account: account)

      policy = TwoFactorAuthenticationPolicy.new(user_context, account_user)

      expect(policy.destroy?).to eq(false)
    end
  end

  def build_user_context_for_carrier(user_attributes = {})
    user_attributes[:carrier_role] ||= :owner
    current_user = create(:user, :carrier, user_attributes)
    organization = build_stubbed(:organization, organization: current_user.carrier)
    build_stubbed(:user_context, user: current_user, current_organization: organization)
  end

  def build_user_context_for_account(account_membership_attributes = {})
    account_membership_attributes[:user] ||= create(:user)
    account_membership_attributes[:role] ||= :owner
    current_account_membership = create(:account_membership, account_membership_attributes)
    organization = build_stubbed(:organization, organization: current_account_membership.account)
    build_stubbed(
      :user_context,
      user: current_account_membership.user,
      current_organization: organization,
      current_account_membership: current_account_membership
    )
  end
end
