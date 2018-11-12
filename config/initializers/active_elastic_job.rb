Rails.application.configure do
  config.active_elastic_job.secret_key_base = Rails.configuration.app_settings.fetch("secret_key_base")
end
