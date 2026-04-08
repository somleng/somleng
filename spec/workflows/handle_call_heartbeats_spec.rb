require "rails_helper"

RSpec.describe HandleCallHeartbeats do
  it "updates the last heartbeat at for the phone calls" do
    phone_call_already_heartbeat = create(
      :phone_call,
      :answered,
      last_heartbeat_at: 1.minute.ago
    )
    phone_call_without_heartbeat = create(
      :phone_call,
      :answered,
      last_heartbeat_at: nil
    )

    freeze_time do
      HandleCallHeartbeats.call(
        [
          phone_call_already_heartbeat.external_id,
          phone_call_without_heartbeat.external_id
        ]
      )


      expect(phone_call_already_heartbeat.reload).to have_attributes(
        last_heartbeat_at: Time.current
      )
      expect(phone_call_without_heartbeat.reload).to have_attributes(
        last_heartbeat_at: Time.current
      )
    end
  end
end
