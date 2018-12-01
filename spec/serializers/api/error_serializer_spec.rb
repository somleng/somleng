require "rails_helper"

module API
  RSpec.describe ErrorSerializer do
    it "serializes a Dry validation result" do
      errors = { "To" => ["is missing"] }

      serializable = instance_double(
        Dry::Validation::Result, errors: errors
      )

      json = described_class.new(serializable, status_code: 422).to_json

      expect(json).to match_response_schema(:"api/error")
      parsed_json = JSON.parse(json)
      expect(parsed_json.fetch("errors")).to eq(errors)

      expect(parsed_json.fetch("status")).to eq(422)
    end

    it "serializes ActiveModel::Model errors" do
      serializable = PhoneCall.new
      serializable.valid?

      json = described_class.new(serializable).to_json

      expect(json).to match_response_schema(:"api/error")
      parsed_json = JSON.parse(json)
      expect(parsed_json.fetch("message")).to be_present
    end
  end
end
