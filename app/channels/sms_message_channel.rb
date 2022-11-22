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
      message.mark_as_sent!
    when "failed"
      message.mark_as_failed!
    else
      raise "Unknown message status: #{data.fetch('status')}"
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
    if schema.valid?
      message = Message.create!(schema.output)
      notify_message_status_callback(message) if message.status_callback_url.present?
      create_interaction(message)
    else
      ErrorLog.create!(
        carrier: error_log_messages.carrier,
        account: error_log_messages.account,
        error_message: error_log_messages.messages.to_sentence
      )
    end
  end

  private

  def create_interaction(message)
    Interaction.create_or_find_by!(interactable: message) do |interaction|
      interaction.attributes = {
        carrier: message.carrier,
        account: message.account,
        beneficiary_country_code: message.beneficiary_country_code,
        beneficiary_fingerprint: message.beneficiary_fingerprint
      }
    end
  end

  def notify_message_status_callback(message)
    NotifyStatusCallback.call(
      account: message.account,
      callback_url: message.status_callback_url,
      callback_http_method: message.status_callback_method,
      params: TwilioAPI::MessageStatusCallbackSerializer.new(
        MessageDecorator.new(message)
      ).serializable_hash
    )
  end
end
