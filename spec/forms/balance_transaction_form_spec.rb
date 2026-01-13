require "rails_helper"

RSpec.describe BalanceTransactionForm do
  it "validates the amount" do
    form = BalanceTransactionForm.new

    form.amount = "-100"
    form.type = "topup"
    form.valid?
    expect(form.errors[:amount]).to be_present

    form.amount = "100"
    form.type = "topup"
    form.valid?
    expect(form.errors[:amount]).to be_blank

    form.amount = "0"
    form.type = "adjustment"
    form.valid?
    expect(form.errors[:amount]).to be_present

    form.amount = "-100"
    form.type = "adjustment"
    form.valid?
    expect(form.errors[:amount]).to be_blank
  end
end
