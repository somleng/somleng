class ProcessRecording < ApplicationWorkflow
  attr_reader :recording

  def initialize(recording)
    @recording = recording
  end

  def call
    file = s3_resource.bucket(
      raw_recording_bucket_name
    ).object(recording_object_name).get
    recording.file.attach(io: file, filename: File.basename(file))
    recording.complete!

    ExecuteWorkflowJob.perform_later(NotifyRecordingStatusCallback.to_s, recording)
  end

  def s3_resource
    @s3_resource ||= Aws::S3::Resource.new
  end

  def raw_recording_bucket_name
    AppSettings.fetch(:raw_recording_bucket_name)
  end

  def recording_object_name
    URI(recording.raw_recording_url).path
  end
end
