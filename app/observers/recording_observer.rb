class RecordingObserver < ApplicationObserver
  def recording_completed(recording)
    if recording.status_callback_url.present?
      RecordingStatusCallbackNotifierJob.perform_later(recording.id)
    end
  end
end
