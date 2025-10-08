class SMSMessageChannel < ApplicationCable::Channel
  def subscribed
    stream_for(current_sms_gateway)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def sent(data)
    message = current_sms_gateway.messages.find(data.fetch("id"))
    case data.fetch("status")
    when "sent"
      handle_sent_event(message)
    when "delivered"
      handle_delivered_event(message)
    when "failed"
      UpdateMessageStatus.new(message).call { message.mark_as_failed! }
    end
  end

  def received(data)
    error_log_messages = ErrorLogMessages.new
    schema = Services::InboundMessageRequestSchema.new(
      input_params: data,
      options: {
        sms_gateway: current_sms_gateway,
        error_log_messages:
      }
    )

    if schema.success?
      attributes = schema.output
      return if drop_message?(attributes)

      message = Message.create!(attributes)
      create_interaction(message)

      ExecuteWorkflowJob.perform_later(
        "ExecuteMessagingTwiML",
        message:,
        url: message.sms_url,
        http_method: message.sms_method
      )
    elsif error_log_messages.messages.present?
      CreateErrorLog.call(
        type: :inbound_message,
        carrier: error_log_messages.carrier,
        account: error_log_messages.account,
        error_message: error_log_messages.messages.to_sentence
      )
    end
  end

  def verify_sending(data)
    message = current_sms_gateway.messages.sending.find(data.fetch("id"))
    SentMessageSMSGateway.create!(message:, sms_gateway: current_sms_gateway)

    transmit({
      type: "confirmed_sending",
      timestamp: message.created_at.to_i,
      message: {
        id: message.id,
        body: message.body,
        to: message.to.to_s,
        from: message.from.to_s,
        channel: message.channel
      }
    })
  end

  private

  def handle_sent_event(message)
    message.transaction do
      UpdateMessageStatus.new(message).call { message.mark_as_sent! }
      CreateEvent.call(eventable: message, type: "message.sent")
      create_interaction(message)
    end
  end

  def handle_delivered_event(message)
    message.transaction do
      UpdateMessageStatus.new(message).call { message.mark_as_delivered! }
      CreateEvent.call(eventable: message, type: "message.delivered")
      create_interaction(message)
    end
  end

  def drop_message?(attributes)
    return false if attributes[:messaging_service].blank?

    attributes.fetch(:messaging_service).inbound_message_behavior.drop?
  end

  def create_interaction(message)
    Interaction.create_or_find_by!(message:) do |interaction|
      interaction.attributes = {
        interactable_type: "Message",
        carrier: message.carrier,
        account: message.account,
        beneficiary_country_code: message.beneficiary_country_code,
        beneficiary_fingerprint: message.beneficiary_fingerprint
      }
    end
  end
end
