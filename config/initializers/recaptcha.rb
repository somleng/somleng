Recaptcha.configure do |config|
  config.site_key = Rails.configuration.app_settings.fetch(:recaptcha_site_key)
  config.secret_key = Rails.configuration.app_settings.fetch(:recaptcha_secret_key)
  config.skip_verify_env += [ "development" ]
end
