class HourlyJob < ApplicationJob
  queue_as AppSettings.config_for(:aws_sqs_low_priority_queue_name)

  def perform
    ExecuteWorkflowJob.perform_later(ExpireInProgressPhoneCalls.to_s)
    ExecuteWorkflowJob.perform_later(ExpireInitiatingPhoneCalls.to_s)
  end
end
