require "rails_helper"

RSpec.describe QueueOutboundMessage do
  it "queues a message" do
    message = create(:message, :accepted)
    incoming_phone_number = create(:incoming_phone_number, account: message.account, messaging_service: message.messaging_service)

    QueueOutboundMessage.call(message)

    expect(message).to have_attributes(
      queued?: true,
      from: incoming_phone_number.number,
      sender_id: incoming_phone_number.number,
      phone_number: incoming_phone_number.phone_number
    )
  end

  it "handles sms gateway sender id behavior" do
    sms_gateway = create(:sms_gateway, :override, sender_id: "1111")
    account = create(:account, carrier: sms_gateway.carrier)
    messaging_service = create(:messaging_service, account:)
    incoming_phone_number = create(:incoming_phone_number, account:, messaging_service:)
    message = create(:message, :accepted, from: nil, account:, messaging_service:, sms_gateway:)

    QueueOutboundMessage.call(message)

    expect(message).to have_attributes(
      queued?: true,
      from: incoming_phone_number.number,
      sender_id: "1111"
    )
  end

  it "handles scheduled messages" do
    message = create(:message, :scheduled)
    create(:incoming_phone_number, account: message.account, messaging_service: message.messaging_service)

    QueueOutboundMessage.call(message)

    expect(message.queued?).to be(true)
  end

  it "marks the message as failed if there are no senders" do
    messaging_service = create(:messaging_service)
    message_with_unconfigured_messaging_service = create(
      :message, :accepted, messaging_service:, account: messaging_service.account
    )
    message_with_deleted_messaging_service = create(:message, :accepted)
    message_with_deleted_messaging_service.messaging_service.destroy!

    QueueOutboundMessage.call(message_with_deleted_messaging_service.reload)

    expected_error = ApplicationError::Errors.fetch(:messaging_service_blank)
    expect(message_with_deleted_messaging_service).to have_attributes(
      status: "failed",
      error_message: expected_error.message,
      error_code: expected_error.code
    )

    QueueOutboundMessage.call(message_with_unconfigured_messaging_service)

    expected_error = ApplicationError::Errors.fetch(:messaging_service_no_senders_available)
    expect(message_with_unconfigured_messaging_service).to have_attributes(
      status: "failed",
      error_message: expected_error.message,
      error_code: expected_error.code
    )
  end
end
