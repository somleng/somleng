class SendPushNotification < ApplicationWorkflow
  attr_reader :devices, :title, :body, :data

  def initialize(devices:, title:, body:, data: {})
    @devices = devices
    @title = title
    @body = body
    @data = data
  end

  def call
    notification = ApplicationPushNotification
      .with_google(data)
      .new(title:, body:)

    notification.deliver_later_to(devices)
  end
end
