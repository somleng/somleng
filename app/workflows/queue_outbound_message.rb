class QueueOutboundMessage < ApplicationWorkflow
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def call
    message.transaction do
      return false if message.phone_number.blank? && !resolve_sender

      UpdateMessageStatus.call(message, event: :queue)
    end
    SendOutboundMessage.call(message)
  end

  private

  def resolve_sender
    return fail!(TwilioAPI::Errors::MessagingServiceBlankError.new) if messaging_service.blank?

    phone_number = messaging_service.phone_numbers.order("RANDOM()").first
    return message.update!(from: phone_number.number, phone_number:) if phone_number.present?

    fail!(TwilioAPI::Errors::MessagingServiceNoSendersAvailableError.new)
  end

  def fail!(error)
    UpdateMessageStatus.call(
      message,
      event: :mark_as_failed,
      error_message: error.message,
      error_code: error.code
    )
    false
  end

  def messaging_service
    message.messaging_service
  end
end
