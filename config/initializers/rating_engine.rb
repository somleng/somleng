CGRateS.configure do |config|
  config.host = AppSettings.fetch(:rating_engine_host)
  config.username = AppSettings.fetch(:rating_engine_username)
  config.password = AppSettings.fetch(:rating_engine_password)
end
