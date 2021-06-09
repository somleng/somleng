require "rails_helper"

RSpec.describe AccountMembershipForm do
  describe "validations" do
    it "validates the email does not belong to a carrier user" do
      user = create(:user, :carrier, email: "johndoe@example.com")

      form = build_form(carrier: user.carrier, email: "johndoe@example.com")

      expect(form).to be_invalid
      expect(form.errors[:email]).to be_present
    end

    it "validates the user is not already a member of the account" do
      account = create(:account)
      user = create(:user, email: "johndoe@example.com")
      create(:account_membership, account: account, user: user)

      form = build_form(account: account, email: "johndoe@example.com")

      expect(form).to be_invalid
      expect(form.errors[:email]).to be_present
    end

    it "allows users to be members of multiple accounts" do
      account = create(:account)
      user = create(:user, email: "johndoe@example.com")
      create(:account_membership, account: account, user: user)
      other_account = create(:account)
      form = build_form(account: other_account, email: "johndoe@example.com")

      form.valid?

      expect(form.errors[:email]).to be_empty
    end

    it "validates the email format" do
      form = build_form(email: "foobar")

      expect(form).to be_invalid
      expect(form.errors[:email]).to be_present
    end
  end

  describe "#save" do
    it "creates an account membership on behalf of a carrier" do
      carrier = create(:carrier)
      account = create(:account, carrier: carrier)
      form = build_form(
        carrier: carrier,
        name: "John Doe",
        email: "johndoe@example.com",
        account_id: account.id
      )

      result = form.save

      expect(result).to eq(true)
      expect(form.account_membership).to have_attributes(
        user: have_attributes(name: "John Doe"),
        account: account,
        role: "owner"
      )
      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
    end

    it "creates an account membership on behalf of an account" do
      account = create(:account)
      form = build_form(account: account, name: "John Doe", email: "johndoe@example.com", role: "admin")

      result = form.save

      expect(result).to eq(true)
      expect(form.account_membership).to have_attributes(
        user: have_attributes(name: "John Doe"),
        account: account,
        role: "admin"
      )
    end

    it "updates an account membership" do
      account = create(:account)
      user = create(:user, name: "John Doe", email: "johndoe@example.com")
      account_membership = create(:account_membership, user: user, account: account, role: "owner")
      form = build_form(account: account, role: "member", account_membership: account_membership)

      result = form.save

      expect(result).to eq(true)
      expect(form.account_membership).to have_attributes(
        user: have_attributes(name: "John Doe"),
        account: account,
        role: "member"
      )
    end
  end

  def build_form(account: nil, carrier: nil, **params)
    form = AccountMembershipForm.new(params)
    carrier ||= create(:carrier) if account.blank?
    account ||= create(:account) if carrier.blank?
    form.current_account = account
    form.current_carrier = carrier
    form
  end
end
