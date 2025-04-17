class AccountRateLimiter
  attr_reader :account, :account_rate_limiters, :carrier_rate_limiters

  def initialize(account, **options)
    @account = account
    @account_rate_limiters = options.fetch(:account_rate_limiters) { build_rate_limiters_for(account) }
    @rate_limiters = options.fetch(:rate_limiters) { build_rate_limiters }
  end

  def with_limit(&)
    rate_limiters.each do |rate_limiter|
      rate_limiter.request!
    end
    yield
  rescue RateLimiter::RateLimitExceededError => e
    puts e.message
    puts e.seconds_remaining_in_current_window
  end

  private

  def build_rate_limiters
    [ account, account.carrier ].each_with_object([]) do |resource, rate_limiters|
      next if resource.calls_per_second.zero?

      [ 10.seconds, 1.minute, 1.hour, 1.day ].each do |window_size|
        rate_limiters << RateLimiter.new(key: resource.id, rate: resource.calls_per_second, window_size:)
      end
    end
  end
end
