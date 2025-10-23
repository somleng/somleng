require "rails_helper"

RSpec.describe SendPushNotification do
  around do |example|
    ActionPushNative::Notification.enabled = true
    example.run
  ensure
    ActionPushNative::Notification.enabled = false
  end

  it "sends a push notification to the devices" do
    devices = create_list(:application_push_device, 2)

    SendPushNotification.call(
      devices: devices,
      title: "New outbound message",
      body:  "[Message: #1]",
      data: {
        type: "message_send_request",
        message_id: 1
      }
    )

    expect(ApplicationPushNotificationJob).to have_been_enqueued.exactly(2).times
    devices.each do |device|
      expect(ApplicationPushNotificationJob).to have_been_enqueued.with(
        "ApplicationPushNotification",
        hash_including(
          title: "New outbound message",
          body:  "[Message: #1]",
          google_data: {
            type: "message_send_request",
            message_id: 1
          }
        ),
        device
      )
    end
  end
end
