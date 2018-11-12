class ApplicationJob < ActiveJob::Base
  def self.aws_sqs_queue_url
    Rails.configuration.app_settings.fetch("#{to_s.underscore}_queue_url") do
      Rails.configuration.app_settings.fetch("default_queue_url")
    end
  end

  queue_as(aws_sqs_queue_url)
end
