class ScheduledJob < ApplicationJob
  queue_as AppSettings.config_for(:aws_sqs_high_priority_queue_name)

  # Jobs cannot be scheduled more than 15 minutes into the future for SQS.
  # See http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SendMessage.html
  MAX_DELAY = 15.minutes

  def perform(job_class, *args)
    options = args.extract_options!
    scheduled_at = Time.at(options.fetch(:wait_until))
    job_args = args.dup
    job_options = options.except(:wait_until)
    job_args << job_options if job_options.present?

    return job_class.constantize.perform_later(*job_args) if scheduled_at.past?

    delay = [ scheduled_at - Time.current, MAX_DELAY ].min
    self.class.set(wait: delay).perform_later(job_class, *args, **options)
  end
end
