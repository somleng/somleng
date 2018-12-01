require "rails_helper"

module API
  module Internal
    RSpec.describe PhoneCallSerializer do
      it "serializes an inbound call" do
        incoming_phone_number = create(:incoming_phone_number, phone_number: "2442")
        phone_call = create(:phone_call, :inbound, incoming_phone_number: incoming_phone_number)

        json = described_class.new(phone_call).to_json

        expect(json).to match_response_schema(:"api/internal/phone_call")
        parsed_json = JSON.parse(json)
        expect(parsed_json.fetch("to")).to eq("2442")
        expect(parsed_json.fetch("direction")).to eq("inbound")
        expect(parsed_json.fetch("routing_instructions")).to be_blank
      end

      it "serializes an outbound call" do
        phone_call = create(:phone_call)

        json = described_class.new(phone_call).to_json

        expect(json).to match_response_schema(:"api/internal/phone_call")
        parsed_json = JSON.parse(json)
        expect(parsed_json.fetch("routing_instructions")).to be_present
        expect(parsed_json.fetch("direction")).to eq("outbound-api")
      end
    end
  end
end
