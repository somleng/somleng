ENV["PGHERO_USERNAME"] = Rails.configuration.app_settings.fetch(:admin_username)
ENV["PGHERO_PASSWORD"] = Rails.configuration.app_settings.fetch(:admin_password)
ENV["PGHERO_DB_INSTANCE_IDENTIFIER"] = Rails.configuration.app_settings.pghero_db_instance_identifier
