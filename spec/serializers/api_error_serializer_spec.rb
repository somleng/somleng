require "rails_helper"

RSpec.describe ApiErrorSerializer do
  it "serializes an API Error" do
    errors = { "To" => ["is missing"] }

    serializable = instance_double(
      Dry::Validation::Result, errors: errors
    )

    json = described_class.new(serializable, status_code: 422).to_json

    expect(json).to match_api_response_schema(:api_error)
    parsed_json = JSON.parse(json)
    expect(parsed_json.fetch("errors")).to eq(errors)
    expect(parsed_json.fetch("message")).to eq("is missing")
    expect(parsed_json.fetch("status")).to eq(422)
  end
end
