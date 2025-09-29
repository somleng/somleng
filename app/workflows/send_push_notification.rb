class SendPushNotification < ApplicationWorkflow
  def initialize(devices:, title:, body:, data: {})
    super()
    @devices = devices
    @title = title
    @body = body
    @data = data
  end

  def call
    notification = ApplicationPushNotification.with_data(data).new(
      title: @title,
      body: @body
    )

    notification.deliver_to(@devices)
  end
end
