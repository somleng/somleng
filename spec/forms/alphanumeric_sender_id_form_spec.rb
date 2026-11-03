require "rails_helper"

RSpec.describe AlphanumericSenderIDForm do
  it 'normalizes the sender id' do
    form = AlphanumericSenderIDForm.new(sender_id: "  Foo  Bar  ")
    expect(form.sender_id).to eq("Foo Bar")
  end

  describe "validations" do
    it "validates the sender id" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      create(:alphanumeric_sender_id, :approved, account:, sender_id: "MyCompany")
      create(:alphanumeric_sender_id, :pending_approval, account:, sender_id: "MyCompany2")

      form = AlphanumericSenderIDForm.new(carrier:, sender_id: "1234")
      form.valid?
      expect(form.errors[:sender_id]).to be_present

      form = AlphanumericSenderIDForm.new(carrier:, sender_id: "A" * 12)
      form.valid?
      expect(form.errors[:sender_id]).to be_present

      form = AlphanumericSenderIDForm.new(carrier:, account:, sender_id: "MyCompany")
      form.valid?
      expect(form.errors[:sender_id]).to be_present

      form = AlphanumericSenderIDForm.new(carrier:, account:, sender_id: "MyCompany2")
      form.valid?
      expect(form.errors[:sender_id]).to be_present
    end

    it "validates the account_id" do
      carrier = create(:carrier)
      form = AlphanumericSenderIDForm.new(carrier:)
      form.valid?
      expect(form.errors[:account_id]).to be_present
    end
  end
end
