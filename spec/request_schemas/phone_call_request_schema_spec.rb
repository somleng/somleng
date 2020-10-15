require "rails_helper"

RSpec.describe PhoneCallRequestSchema, type: :request_schema do
  it "validates To" do
    expect(
      validate_request_schema(input_params: { To: "855716100235" })
    ).to have_valid_field(:To)

    expect(
      validate_request_schema(input_params: { To: "8557199999999" })
    ).not_to have_valid_field(:To)
  end

  it "validates Url" do
    expect(
      validate_request_schema(input_params: { Url: "https://www.example.com" })
    ).to have_valid_field(:Url)

    expect(
      validate_request_schema(input_params: { To: "ftp://www.example.com" })
    ).not_to have_valid_field(:Url)
  end

  it "validates Method" do
    expect(
      validate_request_schema(input_params: { Method: "GET" })
    ).to have_valid_field(:Method)

    expect(
      validate_request_schema(input_params: { Method: "HEAD" })
    ).not_to have_valid_field(:Method)
  end

  it "validates StatusCallback" do
    expect(
      validate_request_schema(input_params: { StatusCallback: "https://www.example.com" })
    ).to have_valid_field(:StatusCallback)

    expect(
      validate_request_schema(input_params: { StatusCallback: "ftp://www.example.com" })
    ).not_to have_valid_field(:StatusCallback)
  end

  it "validates StatusCallbackMethod" do
    expect(
      validate_request_schema(input_params: { StatusCallbackMethod: "GET" })
    ).to have_valid_field(:StatusCallbackMethod)

    expect(
      validate_request_schema(input_params: { StatusCallbackMethod: "HEAD" })
    ).not_to have_valid_field(:StatusCallbackMethod)
  end

  it "handles post processing" do
    schema = validate_request_schema(
      input_params: {
        To: "+855 716 100235",
        From: "1294",
        Url: "https://www.example.com/voice_url.xml"
      }
    )

    expect(schema.output).to eq(
      to: "855716100235",
      from: "1294",
      voice_url: "https://www.example.com/voice_url.xml",
      voice_method: "POST",
      status_callback_url: nil,
      status_callback_method: nil,
      direction: :outbound
    )
  end

  def validate_request_schema(options)
    PhoneCallRequestSchema.new(options)
  end
end
