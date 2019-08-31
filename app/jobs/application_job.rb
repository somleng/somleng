class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def self.aws_sqs_queue_url
    Rails.configuration.app_settings[:"#{to_s.underscore}_queue_url"] || Rails.configuration.app_settings.fetch(:default_queue_url)
  end

  queue_as(aws_sqs_queue_url.split("/").last)
end
