class ApplicationJob < ActiveJob::Base
  def self.aws_sqs_queue_url
    Rails.configuration.app_settings["#{to_s.underscore}_queue_url"] || Rails.configuration.app_settings.fetch("default_queue_url")
  end

  queue_as(aws_sqs_queue_url.split("/").last)
end
