ActionMailer::Base.add_delivery_method(
  :ses, region: Rails.configuration.app_settings.fetch(:aws_ses_region)
)
Aws.config.update(log_level: :warn)
