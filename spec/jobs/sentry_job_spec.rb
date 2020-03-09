require "rails_helper"

RSpec.describe SentryJob do
  describe "#perform" do
    it "posts the event to sentry" do
      event = Raven::Event.new
      expect(Raven).to receive(:send_event).with(event)

      subject.perform(event)
    end
  end
end
