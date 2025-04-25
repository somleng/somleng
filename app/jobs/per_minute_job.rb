class PerMinuteJob < ApplicationJob
  queue_as AppSettings.fetch(:aws_sqs_low_priority_queue_name)

  def perform
    ExecuteWorkflowJob.perform_later(ProcessOutboundCallsQueue.to_s)
  end
end
