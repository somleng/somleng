require "rails_helper"

RSpec.describe SimpleQueue do
  it "handles simple queues" do
    queue = SimpleQueue.new

    queue.enqueue("my-key", "my-item")
    queue.enqueue("my-key", "my-item-2")

    expect(queue.peek("my-key")).to eq("my-item")
    expect(queue.dequeue("my-key")).to eq("my-item")
    expect(queue.dequeue("my-key")).to eq("my-item-2")
    expect(queue.peek("my-key")).to be_nil
    expect(queue.dequeue("my-key")).to be_nil
  end
end
