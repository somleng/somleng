class AddUniqueIndexOnPhoneCallEventsTypeAndPhoneCallId < ActiveRecord::Migration[5.2]
  def change
    add_index(:phone_call_events, %i[phone_call_id type], unique: true)
  end
end
