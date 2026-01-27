require "rails_helper"

RSpec.describe CreateInboundMessage do
  it "creates an inbound message" do
    sms_gateway = create(:sms_gateway)
    account = create(:account, carrier: sms_gateway.carrier, billing_enabled: true)
    create(:tariff_plan_subscription, account:, plan_category: :inbound_messages)
    incoming_phone_number = create(
      :incoming_phone_number,
      :fully_configured,
      account:,
      number: "85510888888",
    )

    stub_rating_engine_request(
      result: build_list(:rating_engine_cdr_response, 1, :success)
    )

    CreateInboundMessage.call(
      carrier: sms_gateway.carrier,
      account:,
      sms_gateway:,
      incoming_phone_number:,
      direction: :inbound,
      encoding: "GSM",
      from: "85510777777",
      to: "85510888888",
      body: "message body",
      segments: 1,
      sms_url: incoming_phone_number.sms_url,
      sms_method: incoming_phone_number.sms_method,
      status: :received,
    )

    expect(sms_gateway.messages.last).to have_attributes(
      carrier: sms_gateway.carrier,
      account:,
      incoming_phone_number:,
      sms_gateway:,
      direction: "inbound",
      encoding: "GSM",
      body: "message body",
      segments: 1,
      interaction: be_present,
      status: "received",
      sms_url: incoming_phone_number.sms_url,
      sms_method: incoming_phone_number.sms_method,
      to: have_attributes(value: "85510888888"),
      from: have_attributes(value: "85510777777"),
    )
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(
      "ExecuteMessagingTwiML",
      message: be_present,
      url: incoming_phone_number.sms_url,
      http_method: incoming_phone_number.sms_method
    )
  end

  it "handles messages configured to be dropped" do
    sms_gateway = create(:sms_gateway)
    account = create(:account, carrier: sms_gateway.carrier)
    messaging_service = create(
      :messaging_service, :drop, account:, carrier: sms_gateway.carrier
    )

    CreateInboundMessage.call(
      carrier: sms_gateway.carrier,
      account:,
      direction: :inbound,
      encoding: "GSM",
      from: "85510777777",
      to: "85510888888",
      body: "message body",
      segments: 1,
      messaging_service:
    )

    expect(sms_gateway.messages).to be_empty
    expect(ErrorLog.count).to eq(0)
  end

  it "handles insufficient balance errors" do
    sms_gateway = create(:sms_gateway)
    account = create(:account, carrier: sms_gateway.carrier, billing_enabled: true)
    create(:tariff_plan_subscription, account:, plan_category: :inbound_messages)

    stub_rating_engine_request(
      result: build_list(:rating_engine_cdr_response, 1, :max_usage_exceeded)
    )

    CreateInboundMessage.call(
      carrier: sms_gateway.carrier,
      account:,
      direction: :inbound,
      encoding: "GSM",
      from: "85510777777",
      to: "85510888888",
      body: "message body",
      segments: 1,
    )

    expect(sms_gateway.messages).to be_empty
    expect(Interaction.count).to eq(0)
    expect(ErrorLog.last).to have_attributes(
      carrier: sms_gateway.carrier,
      account:,
      error_message: ApplicationError::Errors.fetch(:insufficient_balance).message
    )
  end
end
