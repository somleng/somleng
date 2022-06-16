require "rails_helper"

RSpec.describe MP3Converter do
  describe "#convert" do
    it "converts a wav file to mp3" do
      blob = create(:active_storage_attachment, filename: "recording.wav")
      mp3_converter = MP3Converter.new(blob)

      mp3_converter.convert_to_mp3
    end

    it "instrumenting analysis" do
      events = subscribe_events_from("mp3_converter")
      blob = create(:active_storage_attachment, filename: "recording.wav")
      mp3_converter = MP3Converter.new(blob)

      mp3_converter.convert_to_mp3

      expect(events.size).to eq(1)
      expect(events.first.payload).to eq({ converter: "ffmpeg" })
    end
  end

  def subscribe_events_from(name)
    events = []
    ActiveSupport::Notifications.subscribe(name) do |*args|
      events << ActiveSupport::Notifications::Event.new(*args)
    end
    events
  end
end
