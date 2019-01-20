class ProcessRecording < ApplicationWorkflow
  attr_accessor :recording, :bucket_name, :object_key

  def initialize(recording, bucket_name, object_key)
    self.recording = recording
    self.bucket_name = bucket_name
    self.object_key = object_key
  end

  def call
    process_recording
  end

  private

  def process_recording
    recording.process!

    response = fetch_recording
    recording.update_attributes!(
      file_content_type: response.content_type,
      file_filename: File.basename(object_key),
      file: response.body
    )

    recording.complete!
  end

  def fetch_recording
    s3_client.get_object(bucket: bucket_name, key: object_key)
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new
  end
end
