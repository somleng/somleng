require "rails_helper"

RSpec.describe HandleCallHeartbeats do
  it "updates the last heartbeat at for the phone calls" do
    phone_call_already_heartbeat = create(
      :phone_call,
      :answered,
      :with_switch_proxy_identifier,
      last_heartbeat_at: 1.minute.ago
    )
    phone_call_without_heartbeat = create(
      :phone_call,
      :answered,
      :with_switch_proxy_identifier,
      last_heartbeat_at: nil
    )

    freeze_time do
      HandleCallHeartbeats.call([
          phone_call_already_heartbeat.switch_proxy_identifier,
          phone_call_without_heartbeat.switch_proxy_identifier
        ])


      expect(phone_call_already_heartbeat.reload).to have_attributes(
        last_heartbeat_at: Time.current
      )
      expect(phone_call_without_heartbeat.reload).to have_attributes(
        last_heartbeat_at: Time.current
      )
    end
  end
end
