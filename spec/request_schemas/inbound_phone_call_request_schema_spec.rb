require "rails_helper"

RSpec.describe InboundPhoneCallRequestSchema, type: :request_schema do
  it "validates source_ip" do
    _inbound_sip_trunk = create(:inbound_sip_trunk, source_ip: "175.100.7.240")

    expect(
      validate_request_schema(input_params: { source_ip: "175.100.7.240" })
    ).to have_valid_field(:source_ip)

    expect(
      validate_request_schema(input_params: { source_ip: "175.100.7.241" })
    ).not_to have_valid_field(:source_ip)
  end

  it "validates to" do
    carrier = create(:carrier)
    _inbound_sip_trunk = create(:inbound_sip_trunk, carrier: carrier, source_ip: "175.100.7.240")
    _phone_number = create(:phone_number, number: "855716100235", carrier: carrier)

    expect(
      validate_request_schema(input_params: { to: "855716100235", source_ip: "175.100.7.240" })
    ).to have_valid_field(:to)

    expect(
      validate_request_schema(input_params: { to: "85516701721", source_ip: "175.100.7.240" })
    ).not_to have_valid_field(:to)

    expect(
      validate_request_schema(input_params: { to: "855719999999", source_ip: "175.100.7.240" })
    ).not_to have_valid_field(:to)
  end

  it "normalizes the output" do
    carrier = create(:carrier)
    inbound_sip_trunk = create(:inbound_sip_trunk, carrier: carrier, source_ip: "175.100.7.240")
    phone_number = create(:phone_number, carrier: carrier, number: "2442")
    schema = validate_request_schema(
      input_params: {
        source_ip: "175.100.7.240",
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
      inbound_sip_trunk: inbound_sip_trunk,
      variables: {
        "sip_from_host" => "103.9.189.2"
      }
    )
  end

  it "normalizes the from for accounts with a trunk prefix replacement" do
    carrier = create(:carrier)
    _inbound_sip_trunk = create(
      :inbound_sip_trunk,
      carrier: carrier,
      source_ip: "175.100.7.240",
      trunk_prefix_replacement: "855"
    )
    _phone_number = create(:phone_number, number: "855716100235", carrier: carrier)
    schema = validate_request_schema(
      input_params: {
        source_ip: "175.100.7.240",
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
