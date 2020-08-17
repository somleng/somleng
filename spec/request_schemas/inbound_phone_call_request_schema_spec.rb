require "rails_helper"

RSpec.describe InboundPhoneCallRequestSchema, type: :request_schema do
  it "validates To" do
    _incoming_phone_number = create(
      :incoming_phone_number,
      phone_number: "855716100235"
    )

    expect(
      validate_request_schema(input_params: { To: "855716100235" })
    ).to have_valid_field(:To)

    expect(
      validate_request_schema(input_params: { To: "855719999999" })
    ).not_to have_valid_field(:To)
  end

  it "normalizes the output" do
    incoming_phone_number = create(
      :incoming_phone_number,
      phone_number: "2442"
    )
    schema = validate_request_schema(
      input_params: {
        To: "2442",
        From: "855716100230",
        ExternalSid: "external-id",
        Variables: {
          "sip_from_host" => "103.9.189.2"
        }
      }
    )

    expect(schema.output).to include(
      to: "2442",
      from: "855716100230",
      external_id: "external-id",
      incoming_phone_number: incoming_phone_number,
      variables: {
        "sip_from_host" => "103.9.189.2"
      }
    )
  end

  it "normalizes the from for accounts with a trunk prefix replacement" do
    account = create(
      :account,
      settings: {
        trunk_prefix_replacement: "855"
      }
    )
    _incoming_phone_number = create(
      :incoming_phone_number,
      account: account,
      phone_number: "855716100235"
    )
    schema = validate_request_schema(
      input_params: {
        To: "855716100235",
        From: "0716100230",
        ExternalSid: "external-id"
      }
    )

    expect(schema.output).to include(from: "855716100230")
  end

  def validate_request_schema(options)
    InboundPhoneCallRequestSchema.new(options)
  end
end
