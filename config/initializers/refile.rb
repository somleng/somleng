if ENV["CDR_STORAGE"] == "s3" && Rails.env.production?
  require "refile/s3"

  aws = {
    :access_key_id => ENV["AWS_S3_ACCESS_KEY_ID"],
    :secret_access_key => ENV["AWS_S3_SECRET_ACCESS_KEY"],
    :region => ENV["AWS_S3_REGION"],
    :bucket => ENV["AWS_S3_BUCKET"],
    :max_size => (ENV["AWS_S3_MAX_FILE_SIZE_MB"] || 1).to_i.megabytes
  }

  Refile.cache = nil
  Refile.store = Refile::S3.new(:prefix => ENV["AWS_S3_STORE_PREFIX"], **aws)
end
