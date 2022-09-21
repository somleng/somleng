CallService.configure do |config|
  config.host = Rails.configuration.app_settings.fetch(:ahn_host)
  config.username = Rails.configuration.app_settings.fetch(:ahn_username)
  config.password = Rails.configuration.app_settings.fetch(:ahn_password)
  config.queue_url = Rails.configuration.app_settings.fetch(:call_service_queue_url)
  config.logger = Rails.logger
  config.subscriber_realm = "somleng.org"
end
