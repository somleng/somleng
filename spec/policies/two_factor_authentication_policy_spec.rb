require "rails_helper"

RSpec.describe TwoFactorAuthenticationPolicy, type: :policy do
  describe "#new?" do
    it "allows access" do
      user = build_stubbed(:user, otp_required_for_login: false)
      policy = TwoFactorAuthenticationPolicy.new(user, nil)

      expect(policy.new?).to eq(true)
    end

    it "denies access" do
      user = build_stubbed(:user, otp_required_for_login: true)

      policy = TwoFactorAuthenticationPolicy.new(user, nil)

      expect(policy.new?).to eq(false)
    end
  end

  describe "#destroy?" do
    it "denies access to reset 2FA for oneself" do
      user = build_stubbed(:user, :owner, otp_required_for_login: true)

      policy = TwoFactorAuthenticationPolicy.new(user, user)

      expect(policy.destroy?).to eq(false)
    end

    it "denies access for carrier admins" do
      user = create(:user, :admin)
      carrier_user = create(:user, :otp_required_for_login, carrier: user.carrier)

      policy = TwoFactorAuthenticationPolicy.new(user, carrier_user)

      expect(policy.destroy?).to be_falsey
    end

    it "denies access for users outside of carrier" do
      user = create(:user, :owner)
      carrier_user = create(:user, :carrier, :otp_required_for_login)

      policy = TwoFactorAuthenticationPolicy.new(user, carrier_user)

      expect(policy.destroy?).to eq(false)
    end

    it "denies access for users whos 2FA is already disabled" do
      user = create(:user, :owner)
      carrier_user = create(:user, otp_required_for_login: false, carrier: user.carrier)

      policy = TwoFactorAuthenticationPolicy.new(user, carrier_user)

      expect(policy.destroy?).to eq(false)
    end

    it "allows access for carrier owners" do
      user = create(:user, :owner)
      carrier_user = create(:user, :otp_required_for_login, :carrier, carrier: user.carrier)

      policy = TwoFactorAuthenticationPolicy.new(user, carrier_user)

      expect(policy.destroy?).to eq(true)
    end

    it "allows access access to account owners" do
      account_membership = create(:account_membership, :owner)
      other_account_membership = create(:account_membership, account: account_membership.account)

      policy = TwoFactorAuthenticationPolicy.new(account_membership.user, other_account_membership.user)

      expect(policy.destroy?).to eq(true)
    end

    it "denies access access to account admins" do
      account_membership = create(:account_membership, :admin)
      other_account_membership = create(:account_membership, account: account_membership.account)

      policy = TwoFactorAuthenticationPolicy.new(account_membership.user, other_account_membership.user)

      expect(policy.destroy?).to be_falsey
    end

    it "denies access to users outside of account" do
      account_membership = create(:account_membership, :owner)
      other_account_membership = create(:account_membership)

      policy = TwoFactorAuthenticationPolicy.new(account_membership.user, other_account_membership.user)

      expect(policy.destroy?).to eq(false)
    end
  end
end
