require "rails_helper"

RSpec.describe MessagingService do
  describe "#sender_pool" do
    describe "#choose_sender" do
      it "prefers an alphanumeric sender id" do
        messaging_service = create(:messaging_service)
        global_alphanumeric_sender_id = create_alphanumeric_sender_id(messaging_service:, destination_country_code: nil, sender_id: "GlobalRides")
        kh_alphanumeric_sender_id = create_alphanumeric_sender_id(messaging_service:, destination_country_code: "855", sender_id: "KHRides")
        create(:incoming_phone_number, :active, messaging_service:, account: messaging_service.account)

        expect(messaging_service.sender_pool.choose_sender(country_code: "855")).to have_attributes(
          alphanumeric_sender_id: kh_alphanumeric_sender_id,
          sender_id: "KHRides"
        )

        expect(messaging_service.sender_pool.choose_sender(country_code: "61")).to have_attributes(
          alphanumeric_sender_id: global_alphanumeric_sender_id,
          sender_id: "GlobalRides"
        )
      end

      it "chooses a phone number" do
        messaging_service = create(:messaging_service)
        create_alphanumeric_sender_id(messaging_service:, status: :revoked)
        incoming_phone_number = create(
          :incoming_phone_number,
          :active,
          messaging_service:,
          account: messaging_service.account,
          number: "855715100999"
        )

        expect(messaging_service.sender_pool.choose_sender(country_code: "KH")).to have_attributes(
          incoming_phone_number:,
          sender_id: have_attributes(value: "855715100999")
        )
      end
    end

    def create_alphanumeric_sender_id(messaging_service:, destination_country_code: nil, **)
      alphanumeric_sender_id = create(:alphanumeric_sender_id, account: messaging_service.account, status: :approved, **)
      create(:messaging_service_alphanumeric_sender_id, messaging_service:, sender_id: alphanumeric_sender_id, destination_country_code:)
      alphanumeric_sender_id
    end
  end
end
