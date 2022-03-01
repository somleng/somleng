class ProcessRecording < ApplicationWorkflow
  attr_reader :recording, :s3_client

  def initialize(recording, s3_client: Aws::S3::Client.new)
    @recording = recording
    @s3_client = s3_client
  end

  def call
    file = raw_recording_file
    recording.file.attach(io: file, filename: File.basename(file))

    recording.complete!
    ExecuteWorkflowJob.perform_later(NotifyRecordingStatusCallback.to_s, recording)
  end

  def raw_recording_file
    raw_recording_bucket = Aws::S3::Resource.new(client: s3_client).bucket(
      Rails.configuration.app_settings.fetch(:raw_recording_bucket)
    )
    s3_object = raw_recording_bucket.object(
      URI(recording.raw_recording_url).path
    )
    s3_object.get
  end
end