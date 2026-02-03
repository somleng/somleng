require "rails_helper"

RSpec.describe BalanceTransactionForm do
  describe "validations" do
    it "validates the amount" do
      form = build_form(amount: "-100", type: "topup")
      form.valid?
      expect(form.errors[:amount]).to be_present

      form = build_form(amount: "100", type: "topup")
      form.valid?
      expect(form.errors[:amount]).to be_blank

      form = build_form(amount: 10**10, type: "topup")
      form.valid?
      expect(form.errors[:amount]).to be_present

      form = build_form(amount: 10**9, type: "topup")
      form.valid?
      expect(form.errors[:amount]).to be_blank

      form = build_form(amount: -10**10, type: "adjustment")
      form.valid?
      expect(form.errors[:amount]).to be_present

      form = build_form(amount: -10**9, type: "adjustment")
      form.valid?
      expect(form.errors[:amount]).to be_blank

      form = build_form(amount: "0", type: "adjustment")
      form.valid?
      expect(form.errors[:amount]).to be_present

      form = build_form(amount: "-100", type: "adjustment")
      form.valid?
      expect(form.errors[:amount]).to be_blank
    end
  end

  describe "#save" do
    it "saves the form" do
      account = create(:account, billing_currency: "USD")
      form = build_form(account:, amount: "100", type: :topup)

      expect(form.save).to be_truthy

      expect(form.object).to have_attributes(
        amount: InfinitePrecisionMoney.from_amount(100, "USD"),
        type: "topup",
        account:
      )
    end
  end

  def build_form(account: build_stubbed(:account), **)
    BalanceTransactionForm.new(
      carrier: account.carrier,
      account_id: account.id,
      type: "topup",
      amount: "100",
      **
    )
  end
end
