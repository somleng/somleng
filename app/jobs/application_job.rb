class ApplicationJob < ActiveJob::Base
  queue_as(
    Rails.configuration.app_settings.fetch("#{to_s.underscore}_queue_url") do
      Rails.configuration.app_settings.fetch("default_queue_url")
    end
  )
end
