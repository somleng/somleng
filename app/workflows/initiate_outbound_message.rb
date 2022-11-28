class InitiateOutboundMessage < ApplicationWorkflow
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def call
    return unless message.status.in?(%w[queued])
    return message.cancel! if message.validity_period_expired?

    SMSMessageChannel.broadcast_to(
      message.sms_gateway,
      id: message.id,
      body: message.body,
      to: message.to,
      from: message.from,
      channel: message.channel
    )

    message.mark_as_initiated!
  end
end
