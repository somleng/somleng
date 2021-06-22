Sentry.init do |config|
  config.dsn = Rails.configuration.app_settings[:sentry_dsn]
  config.async = ->(event, hint) { Sentry::SendEventJob.perform_later(event, hint) }
end
