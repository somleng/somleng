# frozen_string_literal: true

if Rails.env.production?
  require "refile/s3"

  aws = {
    access_key_id: AppConfig.read(:aws_s3_access_key_id),
    secret_access_key: AppConfig.read(:aws_s3_secret_access_key),
    region: AppConfig.read(:aws_region),
    bucket: AppConfig.read(:uploads_bucket)
  }

  Refile.store = Refile::S3.new(prefix: "store", **aws)
end
