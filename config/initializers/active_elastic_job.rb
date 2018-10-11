Rails.application.configure do
  config.active_elastic_job.secret_key_base = AppConfig.fetch(:secret_key_base)
end
