require "rails_helper"

RSpec.describe AccountMembershipForm do
  describe "validations" do
    it "validates the user is not already a member of the account" do
      account = create(:account)
      user = create(:user, email: "johndoe@example.com")
      create(:account_membership, account: account, user: user)

      form = AccountMembershipForm.new(account: account, email: "johndoe@example.com")

      expect(form).to be_invalid
      expect(form.errors[:email]).to be_present
    end

    it "allows users to be members of multiple accounts" do
      account = create(:account)
      user = create(:user, email: "johndoe@example.com")
      create(:account_membership, account: account, user: user)
      other_account = create(:account)
      form = AccountMembershipForm.new(account: other_account, email: "johndoe@example.com")

      form.valid?

      expect(form.errors[:email]).to be_empty
    end

    it "validates the email format" do
      form = AccountMembershipForm.new(email: "foobar")

      expect(form).to be_invalid
      expect(form.errors[:email]).to be_present
    end
  end

  describe "#save" do
    it "creates an account membership" do
      account = create(:account)
      form = AccountMembershipForm.new(account: account, name: "John Doe", email: "johndoe@example.com", role: "admin")

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
      form = AccountMembershipForm.new(account: account, role: "member", account_membership: account_membership)

      result = form.save

      expect(result).to eq(true)
      expect(form.account_membership).to have_attributes(
        user: have_attributes(name: "John Doe"),
        account: account,
        role: "member"
      )
    end
  end
end
