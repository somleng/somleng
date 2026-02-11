class UpdateMessageStatus < ApplicationWorkflow
  CALLBACK_STATES = %w[queued canceled failed sent delivered].freeze

  attr_reader :message

  def initialize(message)
    super()
    @message = message
  end

  def call(&)
    message.transaction do
      yield(message)
      RedactMessage.call(message) if redact?
      enqueue_status_callback if enqueue_status_callback?
    end
  end

  private

  def redact?
    message.internal? && message.complete? && message.body.present?
  end

  def enqueue_status_callback
    ExecuteWorkflowJob.perform_later(
      TwilioAPI::NotifyWebhook.to_s,
      account: message.account,
      url: message.status_callback_url,
      http_method: "POST",
      params: TwilioAPI::Webhook::MessageStatusCallbackSerializer.new(
        MessageDecorator.new(message)
      ).serializable_hash
    )
  end

  def enqueue_status_callback?
    message.status.in?(CALLBACK_STATES) && message.status_callback_url.present?
  end
end
