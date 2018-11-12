if Rails.env.production?
  require "refile/s3"

  aws = {
    access_key_id: Rails.configuration.app_settings.fetch("aws_s3_access_key_id"),
    secret_access_key: Rails.configuration.app_settings.fetch("aws_s3_secret_access_key"),
    region: Rails.configuration.app_settings.fetch("aws_region"),
    bucket: Rails.configuration.app_settings.fetch("uploads_bucket")
  }

  Refile.store = Refile::S3.new(prefix: "store", **aws)
end
