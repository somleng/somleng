class ProcessRecording < ApplicationWorkflow
  attr_reader :recording, :s3_client

  def initialize(recording, s3_client: Aws::S3::Client.new)
    @recording = recording
    @s3_client = s3_client
  end

  def call
    file = download_raw_recording_file
    recording.file.attach(io: file, filename: "#{recording.id}.wav")
    recording.file.analyze

    recording.complete!
    ExecuteWorkflowJob.perform_later(NotifyRecordingStatusCallback.to_s, recording) if recording.status_callback_url.present?
  end

  private

  def download_raw_recording_file
    raw_recording_bucket = Aws::S3::Resource.new(client: s3_client).bucket(
      Rails.configuration.app_settings.fetch(:raw_recordings_bucket)
    )
    s3_object = raw_recording_bucket.object(
      URI(recording.raw_recording_url).path.delete_prefix("/")
    )
    s3_object.get.body
  end
end
