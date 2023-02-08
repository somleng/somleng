class PgheroCaptureQueryStatsJob < ApplicationJob
  queue_as AppSettings.config_for(:aws_sqs_low_priority_queue_name)

  def perform
    PgHero.capture_query_stats
  end
end
