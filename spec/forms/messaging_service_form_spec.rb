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

    it "validates inbound request URL" do
      form = MessagingServiceForm.new(inbound_message_behavior: :webhook, inbound_request_url: nil)
      form.valid?
      expect(form.errors[:inbound_request_url]).to be_present

      form = MessagingServiceForm.new(
        inbound_message_behavior: :defer_to_sender, inbound_request_url: nil
      )
      form.valid?
      expect(form.errors[:inbound_request_url]).to be_blank

      form = MessagingServiceForm.new(inbound_request_url: "ftp://www.example.com")
      form.valid?
      expect(form.errors[:inbound_request_url]).to be_present
    end

    it "validates the incoming phone number ids" do
      account = create(:account)
      create(:incoming_phone_number, account:)
      messaging_service = create(:messaging_service)

      form = MessagingServiceForm.new(
        name: "My Service",
        account:,
        incoming_phone_number_ids: [ SecureRandom.uuid ],
        messaging_service:
      )

      form.valid?

      expect(form.errors[:incoming_phone_number_ids]).to be_present
    end
  end

  describe "#save" do
    it "correctly sets the messaging service incoming phone numbers" do
      messaging_service = create(:messaging_service)
      _existing_number = create(
        :incoming_phone_number,
        messaging_service:,
        account: messaging_service.account,
      )
      new_number = create(
        :incoming_phone_number,
        account: messaging_service.account
      )

      form = MessagingServiceForm.initialize_with(messaging_service)
      form.incoming_phone_number_ids = [ new_number.id ]

      expect(form.save).to be_truthy

      expect(
        messaging_service.reload.incoming_phone_numbers
      ).to contain_exactly(new_number)
    end
  end
end
