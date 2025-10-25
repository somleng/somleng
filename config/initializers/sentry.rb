Sentry.init do |config|
  config.dsn = Rails.configuration.app_settings[:sentry_dsn]
  config.excluded_exceptions += [
    "ProcessCDRJob::Handler::UnknownPhoneCallError",
    "ProcessCDRJob::Handler::InvalidStateTransitionError",
    "ProcessCDRJob::Handler::CDRAlreadyExistsError",
    "CreatePhoneCallEventJob::Handler::PhoneCallNotFoundError",
    "CreatePhoneCallEventJob::Handler::InvalidStateTransitionError",
    "ActiveRecord::ConnectionNotEstablished"
  ]
end
