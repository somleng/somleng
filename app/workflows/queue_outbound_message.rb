class QueueOutboundMessage < ApplicationWorkflow
  class MessagingServiceError < StandardError
    def code
      message.to_sym
    end
  end

  attr_reader :message

  def initialize(message)
    super()
    @message = message
  end

  def call
    message.transaction do
      resolve_sender if message.phone_number.blank?

      UpdateMessageStatus.new(message).call { message.queue! }
      OutboundMessageJob.perform_later(message)
    end
  rescue MessagingServiceError => e
    error = ApplicationError::Errors.fetch(e.code)

    UpdateMessageStatus.new(message).call do
      message.error_message = error.message
      message.error_code = error.code
      message.mark_as_failed!
    end
  end

  private

  def resolve_sender
    raise(MessagingServiceError, :messaging_service_blank) if messaging_service.blank?

    if (incoming_phone_number = messaging_service.incoming_phone_numbers.order("RANDOM()").first)
      message.update!(
        from: incoming_phone_number.number,
        incoming_phone_number:,
        phone_number: incoming_phone_number.phone_number
      )
    else
      raise(MessagingServiceError, :messaging_service_no_senders_available)
    end
  end

  def messaging_service
    message.messaging_service
  end
end
