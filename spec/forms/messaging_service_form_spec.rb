require "rails_helper"

RSpec.describe MessagingServiceForm do
  describe "validations" do
    it "validates the account_id if not explicitly set" do
      form = MessagingServiceForm.new(account_id: nil)

      form.valid?

      expect(form.errors[:account_id]).to be_present

      account = create(:account)
      form = MessagingServiceForm.new(account:, account_id: nil)

      expect(form.errors[:account_id]).to be_blank
    end

    it "validates the name is present" do
      form = MessagingServiceForm.new(name: nil)

      form.valid?

      expect(form.errors[:name]).to be_present
    end

    it "validates the phone numbers" do
      messaging_service = create(:messaging_service)
      existing_sender = create(
        :phone_number,
        :configured,
        messaging_service:,
        account: messaging_service.account,
        carrier: messaging_service.carrier
      )
      phone_number = create(
        :phone_number,
        account: messaging_service.account,
        carrier: messaging_service.carrier
      )
      unassigned_phone_number = create(
        :phone_number,
        carrier: messaging_service.carrier
      )

      form = MessagingServiceForm.initialize_with(messaging_service)
      form.phone_number_ids = [
        existing_sender.id,
        phone_number.id,
        unassigned_phone_number.id
      ]

      expect(form.valid?).to eq(false)
      expect(form.errors[:phone_number_ids]).to be_present
    end
  end

  describe "#save" do
    it "correctly sets the messaging service phone numbers" do
      messaging_service = create(:messaging_service)
      existing_sender = create(
        :phone_number,
        :configured,
        messaging_service:,
        account: messaging_service.account,
        carrier: messaging_service.carrier
      )
      unconfigured_phone_number = create(
        :phone_number,
        account: messaging_service.account,
        carrier: messaging_service.carrier
      )
      configured_phone_number = create(
        :phone_number,
        :configured,
        account: messaging_service.account,
        carrier: messaging_service.carrier
      )

      form = MessagingServiceForm.initialize_with(messaging_service)
      form.phone_number_ids = [
        unconfigured_phone_number.id, configured_phone_number.id
      ]

      expect(form.save).to be_truthy
      expect(
        messaging_service.reload.phone_numbers
      ).to match_array([unconfigured_phone_number, configured_phone_number])
      expect(existing_sender.configuration).to be_present
    end
  end
end
