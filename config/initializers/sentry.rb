if (sentry_dsn = Rails.configuration.app_settings[:sentry_dsn].presence)
  Raven.configure do |config|
    config.dsn = sentry_dsn
    config.environments = %w[production]
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.async = ->(event, hint) { Sentry::SendEventJob.perform_later(event, hint) }
  end
end
