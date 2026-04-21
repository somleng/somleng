class DailyJob < ApplicationJob
  queue_as AppSettings.fetch(:aws_sqs_low_priority_queue_name)

  def perform
    ExecuteWorkflowJob.perform_later(ExpireQueuedPhoneCalls.to_s)
    ExecuteWorkflowJob.perform_later(PublishInteractionData.to_s)
    ExecuteWorkflowJob.perform_later(DeleteExpiredCarriers.to_s)
  end
end
