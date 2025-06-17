require "rails_helper"

RSpec.describe ProcessOutboundCallsQueue do
  it "enqueues a job to process each call" do
    accounts = create_list(:account, 2)
    accounts.each do |account|
      2.times { OutboundCallsQueue.new(account).enqueue(SecureRandom.uuid) }
    end

    ProcessOutboundCallsQueue.call

    accounts.each do |account|
      expect(OutboundCallJob).to have_been_enqueued.with(account).exactly(2).times
    end
  end

  it "enqueues a maximum of 60 jobs per account" do
    account = create(:account)
    100.times { OutboundCallsQueue.new(account).enqueue(SecureRandom.uuid) }

    ProcessOutboundCallsQueue.call

    expect(OutboundCallJob).to have_been_enqueued.with(account).exactly(60).times
  end
end
