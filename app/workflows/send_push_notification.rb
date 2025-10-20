class SendPushNotification < ApplicationWorkflow
  attr_reader :devices, :title, :body, :data

  def initialize(devices:, title:, body:, data: {})
    super()
    @devices = devices
    @title = title
    @body = body
    @data = data
  end

  def call
    notification = ApplicationPushNotification.with_data(data).new(
      title:,
      body:
    )

    notification.deliver_to(devices[0])
  end
end
