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
    return handle_gateway_disconnected unless sms_gateway.connected?

    broadcast_via_websocket
  end

  private

  def sms_gateway
    message.sms_gateway
  end

  def handle_gateway_disconnected
    if sms_gateway.app? && sms_gateway.app_devices.any?
      send_push_notification
    else
      mark_as_failed(:sms_gateway_disconnected)
    end
  end

  def mark_as_failed(error_code)
    error = ApplicationError::Errors.fetch(error_code)

    UpdateMessageStatus.new(message).call do
      message.error_message = error.message
      message.error_code = error.code
      message.mark_as_failed!
    end
  end

  def broadcast_via_websocket
    UpdateMessageStatus.new(message).call { message.mark_as_sending! }

    channel.broadcast_to(
      sms_gateway,
      {
        id: message.id,
        body: message.body,
        to: message.to.to_s,
        from: message.from.to_s,
        channel: message.channel
      }
    )
  end

  def send_push_notification
    UpdateMessageStatus.new(message).call { message.mark_as_sending! }

    SendPushNotification.call(
      devices: sms_gateway.app_devices,
      title: "New outbound message",
      body:  message.body,
      data: {
        message_id: message.id,
        timestamp: message.created_at.to_i
      }
    )
  end
end
