class SendOutboundMessage < ApplicationWorkflow
  attr_reader :message, :channel

  def initialize(message, **options)
    super()
    @message = message
    @channel = options.fetch(:channel) { SMSMessageChannel }
  end

  def call
    return unless message.queued?
    return mark_as_failed(:validity_period_expired) if message.validity_period_expired?
    return mark_as_failed(:sms_gateway_disconnected) unless message.sms_gateway.connected?

    UpdateMessageStatus.new(message).call { message.mark_as_sending! }

    channel.broadcast_to(
      message.sms_gateway,
      {
        id: message.id,
        body: message.body,
        to: message.to.to_s,
        from: message.from.to_s,
        channel: message.channel
      }
    )
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
