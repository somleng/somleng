class QueueOutboundMessage < ApplicationWorkflow
  class MessagingServiceError < StandardError
    def code
      message.to_sym
    end
  end

  attr_reader :message, :originator_id_behavior

  def initialize(message, **options)
    super()
    @message = message
    @originator_id_behavior = options.fetch(:originator_id_behavior) { OriginatorIDBehavior.new(message.sms_gateway.sender_id_behavior) }
  end

  def call
    message.transaction do
      resolve_phone_number if message.incoming_phone_number.blank?

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

  def resolve_phone_number
    raise(MessagingServiceError, :messaging_service_blank) if messaging_service.blank?

    if (incoming_phone_number = messaging_service.incoming_phone_numbers.order("RANDOM()").first)
      from = incoming_phone_number.number
      sender_id = originator_id_behavior.resolve(client_id: from, managed_id: message.sms_gateway.sender_id) if message.sender_id.blank?

      message.update!(
        from:,
        sender_id:,
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
