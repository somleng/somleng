require "rails_helper"

RSpec.describe SimpleCounter do
  it "handles incrementing and decrementing" do
    counter = SimpleCounter.new(key: "my-key")

    2.times { counter.increment }

    expect(counter.count).to eq(2)

    counter.decrement

    expect(counter.count).to eq(1)
  end

  it "handles expiry" do
    counter = SimpleCounter.new(key: "my-key", expiry: 20.minutes)

    counter.increment

    expect(counter.count).to eq(1)

    travel_to(19.minutes.from_now) do
      expect(counter.count).to eq(1)
      counter.increment
      counter.decrement
      expect(counter.count).to eq(1)
    end

    travel_to(21.minutes.from_now) do
      expect(counter.count).to eq(0)
    end
  end
end
