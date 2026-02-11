class RemoveStiFromPhoneCallEvents < ActiveRecord::Migration[6.0]
  def change
    remove_column(:phone_calls, :recording_id)
    remove_column(:phone_call_events, :recording_id)
  end
end
