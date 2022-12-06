class QueueOutboundMessage < ApplicationWorkflow
  class MessagingServiceError < StandardError
    def code
      message.to_sym
    end
  end

  attr_reader :message

  def initialize(message)
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

    if (phone_number = messaging_service.phone_numbers.order("RANDOM()").first)
      message.update!(from: phone_number.number, phone_number:)
    else
      raise(MessagingServiceError, :messaging_service_no_senders_available)
    end
  end

  def messaging_service
    message.messaging_service
  end
end
