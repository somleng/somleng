require "open3"

class ProcessRecording < ApplicationWorkflow
  attr_reader :recording, :s3_client

  def initialize(recording, s3_client: Aws::S3::Client.new)
    @recording = recording
    @s3_client = s3_client
  end

  def call
    Tempfile.create([recording.id, ".wav"]) do |raw_file|
      download_raw_recording_file(raw_file)

      Tempfile.create([recording.id, ".mp3"]) do |mp3_file|
        convert_to_mp3(raw_file, mp3_file)

        recording.file.attach(io: File.open(raw_file), filename: "#{recording.id}.wav")
        recording.mp3_file.attach(io: File.open(mp3_file), filename: "#{recording.id}.mp3")

        recording.file.analyze
        recording.mp3_file.analyze

        recording.complete!
      end

      ExecuteWorkflowJob.perform_later(NotifyRecordingStatusCallback.to_s, recording) if recording.status_callback_url.present?
    end
  end

  private

  def download_raw_recording_file(output_file)
    s3_client.get_object(
      response_target: output_file.path,
      bucket: Rails.configuration.app_settings.fetch(:raw_recordings_bucket),
      key: URI(recording.raw_recording_url).path.delete_prefix("/")
    )
  end

  def convert_to_mp3(raw_file, mp3_file)
    _stdout_str, error_str, status = Open3.capture3("ffmpeg", "-y", "-i", raw_file.path, mp3_file.path)
    raise StandardError, error_str unless status.success?
  end
end
