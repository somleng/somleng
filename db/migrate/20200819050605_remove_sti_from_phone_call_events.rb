class RemoveStiFromPhoneCallEvents < ActiveRecord::Migration[6.0]
  class PhoneCallEventBase < ActiveRecord::Base
    self.table_name = "phone_call_events"
  end

  def change
    remove_column(:phone_call_events, :recording_id)

    reversible do |dir|
      dir.up do
        PhoneCallEventBase.where(type: "PhoneCallEvent::Completed").update_all(type: :completed)
        PhoneCallEventBase.where(type: "PhoneCallEvent::Answered").update_all(type: :answered)
      end
    end
  end
end
