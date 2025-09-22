require "rails_helper"

RSpec.describe UniqueFIFOQueue do
  it "handles queuing" do
    queue = build_queue

    queue.enqueue("my-item")
    queue.enqueue("my-item")
    queue.enqueue("my-item-2")

    expect(queue.peek).to eq("my-item")
    queue.dequeue do |item|
      expect(item).to eq("my-item")
    end

    expect(queue.empty?).to be(false)

    queue.dequeue do |item|
      expect(item).to eq("my-item-2")
    end

    expect(queue.empty?).to be(true)

    items = []

    queue.dequeue { |item| items << item }
    expect(items.empty?).to be(true)

    queue.enqueue("my-item-3")

    expect { queue.dequeue { |item| raise(ArgumentError, "Some Error processing #{item}") } }.to raise_error(ArgumentError)
    expect(queue.size).to eq(1)
    expect(queue.peek).to eq("my-item-3")

    queue.tmp_enqueue("my-item-4")
    expect(queue.enqueue("my-item-4")).to be_falsey
    expect(queue.size).to eq(1)
    expect(queue.peek).to eq("my-item-3")
  end

  it "recovers items in the tmp queue" do
    queue = build_queue

    queue.recover!(processing_longer_than: 1.minute.ago)

    expect(queue.size).to eq(0)

    queue.tmp_enqueue("my-item-1", score: 2.minutes.ago, processing_started_at: 2.minute.ago)
    queue.tmp_enqueue("my-item-2")

    queue.recover!(processing_longer_than: 1.minute.ago)

    expect(queue.size).to eq(1)
    expect(queue.peek).to eq("my-item-1")
    expect(queue.tmp_size).to eq(1)
    expect(queue.tmp_peek).to eq("my-item-2")
  end

  def build_queue(**options)
    options = {
      key: "my-queue",
      **options
    }

    build_test_queue(UniqueFIFOQueue.new(**options))
  end
end
