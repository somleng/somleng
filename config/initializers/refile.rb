if Rails.env.production?
  require "refile/s3"

  aws = {
    access_key_id: AppConfig.fetch(:aws_s3_access_key_id),
    secret_access_key: AppConfig.fetch(:aws_s3_secret_access_key),
    region: AppConfig.fetch(:aws_region),
    bucket: AppConfig.fetch(:uploads_bucket)
  }

  Refile.store = Refile::S3.new(prefix: "store", **aws)
end
