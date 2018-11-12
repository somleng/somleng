if (sentry_dsn = Rails.configuration.app_settings["sentry_dsn"].presence)
  Raven.configure do |config|
    config.dsn = sentry_dsn
    config.environments = %w[staging production]
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.async = ->(event) { SentryJob.perform_later(event.to_hash) }
  end
end
