CallService.configure do |config|
  config.host = Rails.configuration.app_settings.fetch(:ahn_host)
  config.username = Rails.configuration.app_settings.fetch(:ahn_username)
  config.password = Rails.configuration.app_settings.fetch(:ahn_password)
end
