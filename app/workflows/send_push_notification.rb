class SendPushNotification < ApplicationWorkflow
  def initialize(devices:, title:, body:)
    super()
    @devices = devices
    @title = title
    @body = body
  end

  def call
    notification = ApplicationPushNotification.new(
      title: @title,
      body: @body
    )

    notification.deliver_to(@devices)
  end
end
