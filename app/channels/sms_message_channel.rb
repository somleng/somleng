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
      message = CreateMessage.call(schema.output)

      ExecuteWorkflowJob.perform_later(
        "ExecuteMessagingTwiML",
        message,
        url: message.url,
        http_method: message.sms_method
      )
    else
      ErrorLog.create!(
        carrier: error_log_messages.carrier,
        account: error_log_messages.account,
        error_message: error_log_messages.messages.to_sentence
      )
    end
  end
end
