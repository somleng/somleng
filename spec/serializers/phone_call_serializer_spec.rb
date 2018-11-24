require "rails_helper"

RSpec.describe PhoneCallSerializer do
  it "serializes a newly created call" do
    phone_call = create(
      :phone_call,
      :queued,
      call_data_record: nil,
      from: "1294",
      to: "+85512345678"
    )

    json = described_class.new(phone_call).to_json

    expect(json).to match_api_response_schema(:phone_call)
    parsed_json = JSON.parse(json)
    expect(parsed_json.fetch("account_sid")).to eq(phone_call.account_id)
    expect(parsed_json.fetch("date_created")).to eq(phone_call.created_at.rfc2822)
    expect(parsed_json.fetch("date_updated")).to eq(phone_call.updated_at.rfc2822)
    expect(parsed_json.fetch("duration")).to eq(nil)
    expect(parsed_json.fetch("direction")).to eq("outbound-api")
    expect(parsed_json.fetch("start_time")).to eq(nil)
    expect(parsed_json.fetch("end_time")).to eq(nil)
    expect(parsed_json.fetch("from")).to eq("1294")
    expect(parsed_json.fetch("from_formatted")).to eq("+1 (294) ")
    expect(parsed_json.fetch("to")).to eq("+85512345678")
    expect(parsed_json.fetch("to_formatted")).to eq("+855 12 345 678")
    expect(parsed_json.fetch("sid")).to eq(phone_call.id)
    expect(parsed_json.fetch("status")).to eq("queued")
    expect(parsed_json.fetch("uri")).to eq(
      url_helpers.api_twilio_account_call_path(phone_call.account, phone_call)
    )
    expect(parsed_json.fetch("subresource_uris")).to eq(
      "recordings" => url_helpers.api_twilio_account_call_recordings_path(
        phone_call.account, phone_call.id
      )
    )
  end

  it "serializes a completed call" do
    phone_call = create(:phone_call, :completed)
    cdr = create(:call_data_record, :outbound, :billable, phone_call: phone_call)

    json = described_class.new(phone_call).to_json

    expect(json).to match_api_response_schema(:phone_call)
    parsed_json = JSON.parse(json)
    expect(parsed_json.fetch("direction")).to eq("outbound-api")
    expect(parsed_json.fetch("duration")).to eq(cdr.bill_sec)
    expect(parsed_json.fetch("start_time")).to eq(cdr.answer_time.rfc2822)
    expect(parsed_json.fetch("end_time")).to eq(cdr.end_time.rfc2822)
  end

  it "serializes an incoming call" do
    phone_number = create(:incoming_phone_number)
    phone_call = create(
      :phone_call,
      :completed,
      incoming_phone_number: phone_number,
      account: phone_number.account
    )
    create(:call_data_record, :inbound, :billable, phone_call: phone_call)

    json = described_class.new(phone_call).to_json

    expect(json).to match_api_response_schema(:phone_call)
    parsed_json = JSON.parse(json)
    expect(parsed_json.fetch("direction")).to eq("inbound")
    expect(parsed_json.fetch("phone_number_sid")).to eq(phone_number.id)
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
