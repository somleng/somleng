require "rails_helper"

RSpec.describe ProcessMediaStreamEvent do
  it "processes a media stream events" do
    media_stream = create(:media_stream, :initialized)

    ProcessMediaStreamEvent.call(create(:media_stream_event, :connect, media_stream:))
    expect(media_stream.status).to eq("connected")

    ProcessMediaStreamEvent.call(create(:media_stream_event, :start, media_stream:))
    expect(media_stream.status).to eq("started")

    ProcessMediaStreamEvent.call(create(:media_stream_event, :disconnect, media_stream:))
    expect(media_stream.status).to eq("disconnected")
  end
end
