class RecordingObserver < ApplicationObserver
  def recording_completed(recording)
    if recording.status_callback_url.present?
      JobAdapter.new(:recording_status_callback_notifier_worker).perform_later(recording.id)
    end
  end
end
