CGRateS.configure do |config|
  config.host = Rails.configuration.app_settings.fetch(:rating_engine_host)
  config.username = Rails.configuration.app_settings.fetch(:rating_engine_username)
  config.password = Rails.configuration.app_settings.fetch(:rating_engine_password)
end
