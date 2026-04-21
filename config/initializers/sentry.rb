Sentry.init do |config|
  config.traces_sample_rate = 0.1

  config.dsn = Rails.configuration.app_settings[:sentry_dsn]
  config.excluded_exceptions += [
    "ProcessCDRJob::Handler::UnknownPhoneCallError",
    "ProcessCDRJob::Handler::InvalidStateTransitionError",
    "ProcessCDRJob::Handler::CDRAlreadyExistsError",
    "CreatePhoneCallEventJob::Handler::PhoneCallNotFoundError",
    "CreatePhoneCallEventJob::Handler::InvalidStateTransitionError"
  ]
end
