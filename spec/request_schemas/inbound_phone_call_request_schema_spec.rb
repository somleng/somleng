require "rails_helper"

RSpec.describe InboundPhoneCallRequestSchema, type: :request_schema do
  it "validates to" do
    _phone_number = create(:phone_number, number: "855716100235")

    expect(
      validate_request_schema(input_params: { to: "855716100235" })
    ).to have_valid_field(:to)

    expect(
      validate_request_schema(input_params: { to: "85516701721" })
    ).not_to have_valid_field(:to)

    expect(
      validate_request_schema(input_params: { to: "855719999999" })
    ).not_to have_valid_field(:to)
  end

  it "normalizes the output" do
    phone_number = create(:phone_number, number: "2442")
    schema = validate_request_schema(
      input_params: {
        to: "2442",
        from: "855716100230",
        external_id: "external-id",
        variables: {
          "sip_from_host" => "103.9.189.2"
        }
      }
    )

    expect(schema.output).to include(
      to: "2442",
      from: "855716100230",
      external_id: "external-id",
      phone_number: phone_number,
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
    _phone_number = create(
      :phone_number,
      account: account,
      phone_number: "855716100235"
    )
    schema = validate_request_schema(
      input_params: {
        to: "855716100235",
        from: "0716100230",
        external_id: "external-id"
      }
    )

    expect(schema.output).to include(from: "855716100230")
  end

  def validate_request_schema(options)
    InboundPhoneCallRequestSchema.new(options)
  end
end
