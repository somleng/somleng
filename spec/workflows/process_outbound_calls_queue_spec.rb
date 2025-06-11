require "rails_helper"

RSpec.describe ProcessOutboundCallsQueue do
  it "enqueues outbound call jobs" do
    accounts = create_list(:account, 2)
    accounts.each do |account|
      2.times { OutboundCallsQueue.new(account).enqueue(SecureRandom.uuid) }
    end

    ProcessOutboundCallsQueue.call

    accounts.each do |account|
      expect(OutboundCallJob).to have_been_enqueued.with(account).exactly(1).times
    end
  end
end
