require "rails_helper"

RSpec.describe UniqueFIFOQueue do
  it "handles simple queues" do
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
    expect(queue.peek).to eq("my-item-3")
    expect(queue.size).to eq(1)
  end

  def build_queue(**options)
    options = {
      key: "my-queue",
      **options
    }

    UniqueFIFOQueue.new(**options)
  end
end
