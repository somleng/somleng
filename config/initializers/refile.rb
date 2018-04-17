# frozen_string_literal: true

if Rails.env.production?
  require 'refile/s3'

  aws = {
    access_key_id: Rails.application.secrets.fetch(:aws_s3_access_key_id),
    secret_access_key: Rails.application.secrets.fetch(:aws_s3_secret_access_key),
    region: Rails.application.secrets.fetch(:aws_region),
    bucket: Rails.application.secrets.fetch(:uploads_bucket)
  }

  Refile.store = Refile::S3.new(prefix: 'store', **aws)
end
