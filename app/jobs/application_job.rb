class ApplicationJob < ActiveJob::Base
  def self.parse_queue_name(queue_url)
    queue_url.split("/").last
  end

  def self.default_queue_name
    parse_queue_name(Rails.configuration.app_settings.fetch("default_queue_url"))
  end

  queue_as(default_queue_name)
end
