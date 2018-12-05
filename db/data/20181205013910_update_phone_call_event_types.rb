class UpdatePhoneCallEventTypes < ActiveRecord::Migration[5.2]
  def up
    PhoneCallEvent.where(type: "PhoneCallEvent::Answered").update_all(type: :answered)
    PhoneCallEvent.where(type: "PhoneCallEvent::Completed").update_all(type: :completed)
    PhoneCallEvent.where(type: "PhoneCallEvent::RecordingCompleted").update_all(type: :recording_completed)
    PhoneCallEvent.where(type: "PhoneCallEvent::RecordingStarted").update_all(type: :recording_started)
    PhoneCallEvent.where(type: "PhoneCallEvent::Ringing").update_all(type: :ringing)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
