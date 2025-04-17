class SchedulerJob
  include Shoryuken::Worker

  shoryuken_options(
    queue: AppSettings.fetch(:aws_sqs_scheduler_queue_name),
    auto_delete: true,
    body_parser: :json
  )

  def perform(_sqs_message, params)
    job_class = params.fetch("job_class")
    Shoryuken.logger.info("Performing #{job_class}")

    job_class.constantize.perform_later
  end
end
