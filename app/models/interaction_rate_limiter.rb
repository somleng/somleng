class InteractionRateLimiter
  class RateLimitExceededError < RateLimiter::RateLimitExceededError; end

  attr_reader :account, :interaction_type, :rate_limiters

  def initialize(account, interaction_type:, **options)
    @account = account
    @interaction_type = interaction_type
    @rate_limiters = options.fetch(:rate_limiters) do
      build_rate_limiters(identifier: options.fetch(:identifier), rate: options.fetch(:limit))
    end
  end

  def request!
    rate_limiters.map do |rate_limiter|
      rate_limiter.request!
    end
  rescue RateLimiter::RateLimitExceededError => e
    raise RateLimitExceededError.new(
      e.message,
      seconds_remaining_in_current_window: e.seconds_remaining_in_current_window
    )
  end

  private

  def limit
    @limit.respond_to?(:call) ? @limit.call(account) : @limit
  end

  def build_rate_limiters(identifier:, rate:)
    [ account, account.carrier ].each_with_object([]) do |owner, rate_limiters|
      owner_rate = rate.respond_to?(:call) ? rate.call(owner) : rate

      next if owner_rate.zero?

      owner_identifier = identifier.respond_to?(:call) ? identifier.call(owner) : identifier
      rate_limiters << RateLimiter.new(key: "#{owner_identifier}:#{interaction_type}", rate: owner_rate, window_size: 10.seconds)
    end
  end
end
