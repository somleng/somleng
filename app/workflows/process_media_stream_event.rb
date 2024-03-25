class ProcessMediaStreamEvent < ApplicationWorkflow
  attr_reader :event, :media_stream

  def initialize(event)
    @event = event
    @media_stream = event.media_stream
  end

  def call
    case event.type
    when "connect"
      media_stream.connect!
    when "start"
      media_stream.start!
    when "disconnect"
      media_stream.disconnect!
    when "connect_failed"
      media_stream.fail_to_connect!
    end
  end
end
