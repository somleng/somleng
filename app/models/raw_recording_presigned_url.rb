class RawRecordingPresignedURL
  attr_reader :object_url

  def initialize(object_url)
    @object_url = object_url
  end

  def presigned_url
    s3_object = Aws::S3::Object.new(
      Rails.configuration.app_settings.fetch(:raw_recordings_bucket),
      URI(object_url).path.delete_prefix("/")
    )
    s3_object.presigned_url(:get)
  end
end
