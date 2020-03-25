if Rails.env.production?
  require "refile/s3"

  aws = {
    region: Rails.configuration.app_settings.fetch(:aws_region),
    bucket: Rails.configuration.app_settings.fetch(:uploads_bucket)
  }

  Refile.cache = Refile::S3.new(prefix: "cache", **aws)
  Refile.store = Refile::S3.new(prefix: "store", **aws)
end
