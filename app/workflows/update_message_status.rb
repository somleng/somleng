class UpdateMessageStatus < ApplicationWorkflow
  CALLBACK_STATES = %w[queued canceled failed sent].freeze

  attr_reader :message, :event, :attributes

  def initialize(message, event:, **attributes)
    @message = message
    @event = event
    @attributes = attributes
  end

  def call
    message.transaction do
      message.fire!(event) do
        enqueue_status_callback
      end
      message.update!(attributes)
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
