ENV["PGHERO_USERNAME"] = Rails.configuration.app_settings.fetch(:admin_username)
ENV["PGHERO_PASSWORD"] = Rails.configuration.app_settings.fetch(:admin_password)
ENV["PGHERO_DB_INSTANCE_IDENTIFIER"] = Rails.configuration.app_settings.pghero_db_instance_identifier

db_config = Rails.configuration.database_configuration[Rails.env]

ENV["PGHERO_OTHER_DATABASES"].to_s.split(",").each do |database_name|
  PgHero.config["databases"][database_name] = {
    "url" => db_config.merge("database" => database_name),
    "db_instance_identifier" => ENV["PGHERO_DB_INSTANCE_IDENTIFIER"]
  }
end
