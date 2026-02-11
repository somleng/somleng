class CreateMessage < ApplicationWorkflow
  attr_reader :params

  def initialize(params = {})
    super()
    @params = params
  end

  def call
    message = Message.create!(params)
    process_message(message)
    message
  end

  private

  def process_message(message)
    if message.queued?
      send_message(message)
    elsif message.accepted?
      queue_message(message)
    elsif message.scheduled?
      schedule_message(message)
    end
  end

  def send_message(message)
    OutboundMessageJob.perform_later(message)
  end

  def queue_message(message)
    ExecuteWorkflowJob.perform_later(QueueOutboundMessage.to_s, message)
  end

  def schedule_message(message)
    ScheduledJob.perform_later(
      QueueOutboundMessage.to_s,
      message,
      wait_until: message.send_at
    )
  end
end
