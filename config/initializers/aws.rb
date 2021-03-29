Aws::Rails.add_action_mailer_delivery_method(:ses, region: "us-east-1")
Aws.config.update(log_level: :warn)
