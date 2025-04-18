require "rails_helper"

RSpec.describe RateLimiter do
  it "handles per second time windows" do
    travel_to(Time.new(2025, 4, 17, 0, 0, 0)) do
      rate = 1
      expect { build_rate_limiter(key: "my-rate-limiter-key", rate:, window_size: 1.second).request! }.not_to raise_error
      expect { build_rate_limiter(key: "my-rate-limiter-key", rate:, window_size: 1.second).request! }.to raise_error(
        an_instance_of(RateLimiter::RateLimitExceededError).and having_attributes(
          seconds_remaining_in_current_window: 1
        )
      )
    end
  end

  it "handles per minute time windows" do
    travel_to(Time.new(2025, 4, 17, 0, 0, 0)) do
      rate = 10.0 / 1.minute
      expect { 10.times { build_rate_limiter(key: "my-rate-limiter-key", rate:, window_size: 1.minute).request! } }.not_to raise_error
      expect { build_rate_limiter(key: "my-rate-limiter-key", rate:, window_size: 1.minute).request! }.to raise_error(
        RateLimiter::RateLimitExceededError
      )
    end
  end

  it "handles per hour time windows" do
    travel_to(Time.new(2025, 4, 17, 0, 0, 0)) do
      rate = 10.0 / 1.hour
      expect { 10.times { build_rate_limiter(key: "my-rate-limiter-key", rate:, window_size: 1.hour).request! } }.not_to raise_error
      expect { build_rate_limiter(key: "my-rate-limiter-key", rate:, window_size: 1.hour).request! }.to raise_error(
        RateLimiter::RateLimitExceededError
      )
    end
  end

  it "handles per day time windows" do
    travel_to(Time.new(2025, 4, 17, 0, 0, 0)) do
      rate = 10.0 / 1.day
      expect { 10.times { build_rate_limiter(key: "my-rate-limiter-key", rate:, window_size: 1.day).request! } }.not_to raise_error
      expect { build_rate_limiter(key: "my-rate-limiter-key", rate:, window_size: 1.day).request! }.to raise_error(
        RateLimiter::RateLimitExceededError
      )
    end
  end

  it "raises an error for invalid time windows" do
    expect { build_rate_limiter(window_size: 2.years) }.to raise_error(ArgumentError, "Invalid duration unit: years")
  end

  def build_rate_limiter(**options)
    options = {
      key: "rate_limiter",
      rate: 1,
      window_size: 1.second,
      **options
    }
    RateLimiter.new(**options)
  end
end
