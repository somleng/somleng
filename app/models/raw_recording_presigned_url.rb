class RawRecordingPresignedURL
  attr_reader :object_key

  def initialize(object_key)
    @object_key = object_key
  end

  def presigned_url
    s3_object = Aws::S3::Object.new(
      Rails.configuration.app_settings.fetch(:raw_recordings_bucket),
      object_key
    )
    s3_object.presigned_url(:get)
  end
end
