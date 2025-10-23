require "rails_helper"

RSpec.describe SendPushNotification do
  it "sends a push notification to the devices" do
    devices = create_list(:application_push_device, 2)

    SendPushNotification.call(
      devices: devices,
      title: "New outbound message",
      body:  "[Message: 1]",
      data: {
        type: "message_send_request",
        message_id: 1
      }
    )
  end
end
