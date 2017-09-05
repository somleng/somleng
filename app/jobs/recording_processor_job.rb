class RecordingProcessorJob < ActiveJob::Base
  def perform(recording_id, bucket_name, object_key)
    recording = Recording.find(recording_id)
    recording.subscribe(RecordingObserver.new)

    recording.process!

    response = s3_client.get_object(
      :bucket => bucket_name,
      :key => object_key
    )

    recording.file_content_type = response.content_type
    recording.file_filename = File.basename(object_key)
    recording.file = response.body
    recording.complete
    recording.save!
  end

  private

  def s3_client
    @s3_client ||= Aws::S3::Client.new
  end
end
