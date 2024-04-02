class SendOutboundMessage < ApplicationWorkflow
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def call
    return unless message.queued?
    return mark_as_failed(:validity_period_expired) if message.validity_period_expired?
    return mark_as_failed(:sms_gateway_disconnected) unless message.sms_gateway.connected?

    SMSMessageChannel.broadcast_to(
      message.sms_gateway,
      {
        id: message.id,
        body: message.body,
        to: message.to,
        from: message.from,
        channel: message.channel
      }
    )

    UpdateMessageStatus.new(message).call { message.mark_as_sending! }
  end

  private

  def mark_as_failed(error_code)
    error = ApplicationError::Errors.fetch(error_code)

    UpdateMessageStatus.new(message).call do
      message.error_message = error.message
      message.error_code = error.code
      message.mark_as_failed!
    end
  end
end
