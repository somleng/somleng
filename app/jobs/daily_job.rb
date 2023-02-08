class DailyJob < ApplicationJob
  queue_as AppSettings.config_for(:aws_sqs_low_priority_queue_name)

  def perform
    ExecuteWorkflowJob.perform_later(ExpireQueuedPhoneCalls.to_s)
    PgHero.capture_space_stats
  end
end
