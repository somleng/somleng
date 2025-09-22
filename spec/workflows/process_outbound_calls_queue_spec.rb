require "rails_helper"

RSpec.describe ProcessOutboundCallsQueue do
  it "recovers the queues" do
    account = create(:account)
    queue = build_test_queue(OutboundCallsQueue.new(account))
    queue.enqueue(SecureRandom.uuid)
    older_item = SecureRandom.uuid
    processing_item = SecureRandom.uuid

    queue.tmp_enqueue(older_item, score: 2.minutes.ago, processing_started_at: 2.minutes.ago)
    queue.tmp_enqueue(processing_item)

    ProcessOutboundCallsQueue.call

    expect(queue.size).to eq(2)
    expect(queue.peek).to eq(older_item)
  end

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
