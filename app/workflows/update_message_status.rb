class UpdateMessageStatus < ApplicationWorkflow
  CALLBACK_STATES = %w[queued canceled failed sent delivered].freeze

  attr_reader :message

  def initialize(message)
    super()
    @message = message
  end

  def call(&_block)
    message.transaction do
      yield
      enqueue_status_callback
    end
  end

  private

  def enqueue_status_callback
    return unless message.status.in?(CALLBACK_STATES)
    return if message.status_callback_url.blank?

    ExecuteWorkflowJob.perform_later(
      "TwilioAPI::NotifyWebhook",
      account: message.account,
      url: message.status_callback_url,
      http_method: "POST",
      params: TwilioAPI::Webhook::MessageStatusCallbackSerializer.new(
        MessageDecorator.new(message)
      ).serializable_hash
    )
  end
end
