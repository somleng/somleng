require "rails_helper"

RSpec.describe InteractionRateLimiter do
  describe "#request!" do
    it "handles account rate limits" do
      account = create(
        :account, calls_per_second: 1,
        carrier: create(:carrier, calls_per_second: 0)
      )
      rate_limiter = build_rate_limiter(account)

      travel_to(Time.new(2025, 4, 18, 0, 0, 0)) do
        expect { 10.times { rate_limiter.request! } }.not_to raise_error

        expect { rate_limiter.request! }.to raise_error(
          an_instance_of(
            InteractionRateLimiter::RateLimitExceededError
          ).and having_attributes(
            seconds_remaining_in_current_window: 10
          )
        )
      end
    end

    it "handles unlimited owner limits" do
      account = create(
        :account, calls_per_second: 0,
        carrier: create(:carrier, calls_per_second: 0)
      )

      rate_limiter = build_rate_limiter(account)

      travel_to(Time.new(2025, 4, 18, 0, 0, 0)) do
        expect { 100.times { rate_limiter.request! } }.not_to raise_error
      end
    end

    it "handles carrier rate limits" do
      carrier = create(:carrier, calls_per_second: 1)
      account_rate_limiter = build_rate_limiter(create(:account, calls_per_second: 1, carrier:))
      other_account_rate_limiter = build_rate_limiter(create(:account, calls_per_second: 1, carrier:))

      travel_to(Time.new(2025, 4, 18, 0, 0, 0)) do
        expect { 5.times { account_rate_limiter.request! } }.not_to raise_error
        expect { 5.times { other_account_rate_limiter.request! } }.not_to raise_error
        expect { account_rate_limiter.request! }.to raise_error(InteractionRateLimiter::RateLimitExceededError)
      end
    end
  end

  def build_rate_limiter(account, **options)
    options = {
      interaction_type: :phone_calls,
      identifier: ->(resource) { resource.id },
      limit: ->(resource) { resource.calls_per_second },
      **options
    }
    InteractionRateLimiter.new(account, **options)
  end
end
