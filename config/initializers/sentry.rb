Sentry.init do |config|
  config.dsn = Rails.configuration.app_settings[:sentry_dsn]
end
