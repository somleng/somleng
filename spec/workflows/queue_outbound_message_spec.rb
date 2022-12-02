require "rails_helper"

RSpec.describe QueueOutboundMessage do
  it "queues a message" do
    message = create(:message, :accepted)
    create(
      :phone_number,
      :configured,
      account: message.account,
      messaging_service: message.messaging_service
    )

    QueueOutboundMessage.call(message)

    expect(message.queued?).to eq(true)
  end

  it "handles scheduled messages" do
    message = create(:message, :scheduled)
    create(
      :phone_number,
      :configured,
      account: message.account,
      messaging_service: message.messaging_service
    )

    QueueOutboundMessage.call(message)

    expect(message.queued?).to eq(true)
  end

  it "marks the message as failed if there are no senders" do
    messaging_service = create(:messaging_service)
    message_with_unconfigured_messaging_service = create(
      :message, :accepted, messaging_service:, account: messaging_service.account
    )
    message_with_deleted_messaging_service = create(:message, :accepted)
    message_with_deleted_messaging_service.messaging_service.destroy!

    QueueOutboundMessage.call(message_with_deleted_messaging_service.reload)

    expected_error = TwilioAPI::Errors.fetch(:messaging_service_blank)
    expect(message_with_deleted_messaging_service).to have_attributes(
      status: "failed",
      error_message: expected_error.message,
      error_code: expected_error.code
    )

    QueueOutboundMessage.call(message_with_unconfigured_messaging_service)

    expected_error = TwilioAPI::Errors.fetch(:messaging_service_no_senders_available)
    expect(message_with_unconfigured_messaging_service).to have_attributes(
      status: "failed",
      error_message: expected_error.message,
      error_code: expected_error.code
    )
  end
end
