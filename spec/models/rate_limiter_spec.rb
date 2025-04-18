require "rails_helper"

RSpec.describe RateLimiter do
  it "raises an error if the rate limit is exceeded" do
    travel_to(Time.new(2025, 4, 17, 0, 0, 0)) do
      expect { build_rate_limiter(key: "my-rate-limiter-key", rate: 1, window_size: 1.second).request! }.not_to raise_error
      expect { build_rate_limiter(key: "my-rate-limiter-key", rate: 1, window_size: 1.second).request! }.to raise_error(
        an_instance_of(RateLimiter::RateLimitExceededError).and having_attributes(
          seconds_remaining_in_current_window: 1
        )
      )
    end

    travel_to(Time.new(2025, 4, 17, 1, 0, 0)) do
      expect { 60.times { build_rate_limiter(key: "my-rate-limiter-key", rate: 1, window_size: 1.minute).request! } }.not_to raise_error
      expect { build_rate_limiter(key: "my-rate-limiter-key", rate: 1, window_size: 1.minute).request! }.to raise_error(
        an_instance_of(RateLimiter::RateLimitExceededError).and having_attributes(
          seconds_remaining_in_current_window: be_present
        )
      )
    end

    travel_to(Time.new(2025, 4, 17, 2, 0, 0)) do
      expect { 3600.times { build_rate_limiter(key: "my-rate-limiter-key", rate: 1, window_size: 1.hour).request! } }.not_to raise_error
      expect { build_rate_limiter(key: "my-rate-limiter-key", rate: 1, window_size: 1.hour).request! }.to raise_error(
        an_instance_of(RateLimiter::RateLimitExceededError).and having_attributes(
          seconds_remaining_in_current_window: be_present
        )
      )
    end
  end

  it "works with window sizes" do
    11.times do |i|
      travel_to(Time.new(2025, 4, 17, 1, 0, i)) do
        expect { build_rate_limiter(rate: 1, window_size: 10.seconds).request! }.not_to raise_error
      end
    end
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
