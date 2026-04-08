class PerMinuteJob < ApplicationJob
  queue_as AppSettings.fetch(:aws_sqs_low_priority_queue_name)

  def perform
    ExecuteWorkflowJob.perform_later(ProcessOutboundCallsQueue.to_s)
    ExecuteWorkflowJob.perform_later(PublishOutboundCallsQueueMetrics.to_s)
    ExecuteWorkflowJob.perform_later(FailSendingMessages.to_s)
    ExecuteWorkflowJob.perform_later(RefreshCarrierRates.to_s)
    ExecuteWorkflowJob.perform_later(SyncRatingEngineTransactions.to_s)

    # NOTE: This may not need to run every minute; running it every five minutes or so might be sufficient.
    ExecuteWorkflowJob.perform_later(ExpireInProgressPhoneCalls.to_s)
  end
end
