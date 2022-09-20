CallService.configure do |config|
  config.host = Rails.configuration.app_settings.fetch(:ahn_host)
  config.username = Rails.configuration.app_settings.fetch(:ahn_username)
  config.password = Rails.configuration.app_settings.fetch(:ahn_password)
  config.queue_url = Rails.configuration.app_settings.fetch(:call_service_queue_url)
  config.function_arn = Rails.configuration.app_settings.fetch(:call_service_function_arn)
  config.subscriber_realm = "somleng.org"
end
