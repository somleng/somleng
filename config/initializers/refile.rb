if ENV["CDR_STORAGE"] == "s3" && Rails.env.production?
  require "refile/s3"

  aws = {
    :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
    :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"],
    :region => ENV["AWS_REGION"],
    :bucket => ENV["AWS_S3_REFILE_BUCKET"]
  }

  if max_size = ENV["AWS_S3_REFILE_MAX_FILE_SIZE_MB"]
    aws.merge!(:max_size => max_size.to_i.megabytes)
  end

  Refile.store = Refile::S3.new(:prefix => ENV["AWS_S3_REFILE_STORE_PREFIX"], **aws)
end
