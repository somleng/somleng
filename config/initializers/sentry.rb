Sentry.init do |config|
  config.dsn = Rails.configuration.app_settings[:sentry_dsn]
  config.excluded_exceptions += [
    "ProcessCDRJob::Handler::UnknownPhoneCallError",
    "UpdatePhoneCallStatus::InvalidStateTransitionError,"
  ]
end
