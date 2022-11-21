class InitiateOutboundMessage < ApplicationWorkflow
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def call
    return unless message.status.in?(%w[queued])

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
