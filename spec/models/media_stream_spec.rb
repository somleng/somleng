require "rails_helper"

RSpec.describe MediaStream do
  it "transitions to connected from initialized" do
    media_stream = create(:media_stream, :initialized)

    media_stream.connect!

    expect(media_stream.status).to eq("connected")
  end

  it "handles out of order events" do
    media_stream = create(:media_stream, :initialized)

    media_stream.start!
    expect(media_stream.status).to eq("started")

    media_stream.connect!
    expect(media_stream.status).to eq("started")
  end

  it "handles out of order connection failures" do
    media_stream = create(:media_stream, :initialized)

    media_stream.disconnect!
    expect(media_stream.status).to eq("initialized")

    media_stream.fail_to_connect!
    expect(media_stream.status).to eq("connect_failed")
  end
end


# event :connect do
#   transitions from: :initialized, to: :connected
# end

# event :start do
#   transitions from: [ :initialized, :connected ], to: :started
# end

# event :fail_to_connect do
#   transitions from: [ :initialized ], to: :connect_failed
# end

# event :disconnect do
#   transitions from: [ :initialized, :connected, :started ], to: :disconnected
# end
