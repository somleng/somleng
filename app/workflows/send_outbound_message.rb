class SendOutboundMessage < ApplicationWorkflow
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def call
    return unless message.queued?
    return update_message_status(:mark_as_failed) if message.validity_period_expired?

    SMSMessageChannel.broadcast_to(
      message.sms_gateway,
      id: message.id,
      body: message.body,
      to: message.to,
      from: message.from,
      channel: message.channel
    )

    update_message_status(:mark_as_sending)
  end

  private

  def update_message_status(event)
    UpdateMessageStatus.call(message, event:)
  end
end
