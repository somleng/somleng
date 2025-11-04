require "rails_helper"

RSpec.describe SendOutboundMessage do
  it "broadcast to sms gateway" do
    message = create_message(:queued)

    expect {
      SendOutboundMessage.call(message)
    }.to have_broadcasted_to(
      message.sms_gateway
    ).from_channel(
      SMSMessageChannel
    ).with(
      type: "message_send_request",
      message_id: message.id
    )

    expect(message.status).to eq("sending")
  end

  it "handles messages that are not queued" do
    message = create_message(:sent)

    SendOutboundMessage.call(message)

    expect(message.status).to eq("sent")
  end

  it "handles expired validity period" do
    message = create_message(:queued, queued_at: 5.seconds.ago, validity_period: 5)

    SendOutboundMessage.call(message)

    expected_error = ApplicationError::Errors.fetch(:validity_period_expired)
    expect(message).to have_attributes(
      status: "failed",
      error_message: expected_error.message,
      error_code: expected_error.code
    )
  end

  it "handles disconnected sms gateways" do
    sms_gateway = create(:sms_gateway, :disconnected)
    message = create(:message, :queued, sms_gateway:, carrier: sms_gateway.carrier)

    SendOutboundMessage.call(message)

    expected_error = ApplicationError::Errors.fetch(:sms_gateway_disconnected)
    expect(message).to have_attributes(
      status: "failed",
      error_message: expected_error.message,
      error_code: expected_error.code
    )
  end

  it "keeps updates the state even if the broadcast fails" do
    message = create_message(:queued)
    channel = class_double(SMSMessageChannel)
    allow(channel).to receive(:broadcast_to).and_raise(StandardError.new)

    expect { SendOutboundMessage.call(message, channel:) }.to raise_error(StandardError)

    expect(message).to have_attributes(
      status: "sending"
    )
  end

  def create_message(*args)
    options = args.extract_options!
    sms_gateway = create(:sms_gateway, :connected)
    account = create(:account, carrier: sms_gateway.carrier)
    create(:message, *args, sms_gateway:, account:, **options)
  end
end
