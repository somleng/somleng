require "rails_helper"

RSpec.describe OutboundCallsQueue do
  describe ".each_queue" do
    it "yields each queue" do
      queues = Array.new(4) { build_queue }

      queues[0].enqueue(SecureRandom.uuid)
      queues[0].tmp_enqueue(SecureRandom.uuid)
      queues[1].enqueue(SecureRandom.uuid)
      queues[2].tmp_enqueue(SecureRandom.uuid)

      yielded_queues = []

      OutboundCallsQueue.each_queue do |queue|
        yielded_queues << queue
      end

      expect(yielded_queues.size).to eq(3)
      expect(yielded_queues.map(&:account)).to match_array(queues[0..2].map(&:account))
    end
  end

  def build_queue(account: create(:account))
    build_test_queue(OutboundCallsQueue.new(account))
  end
end
