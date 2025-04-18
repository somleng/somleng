class OutboundCallJob < ApplicationJob
  class Handler
    attr_reader :account, :queue, :rate_limiter

    def initialize(account, **options)
      @account = account
      @queue = options.fetch(:queue) { InteractionQueue.new(account, interaction_type: :outbound_calls) }
      @rate_limiter = options.fetch(:rate_limiter) { build_rate_limiter }
    end

    def perform
      rate_limiter.request!
      ExecuteWorkflowJob.perform_later(InitiateOutboundCall.to_s, phone_call_id: queue.dequeue)
    rescue InteractionRateLimiter::RateLimitExceededError => e
      OutboundCallJob.perform_later(
        account,
        wait_until: e.seconds_remaining_in_current_window.seconds.from_now
      )
    end

    private

    def build_rate_limiter
      InteractionRateLimiter.new(
        account,
        interaction_type: :outbound_calls,
        identifier: ->(resource) { resource.id },
        limit: ->(resource) { resource.calls_per_second }
      )
    end
  end

  def perform(...)
    Handler.new(...).perform
  end
end
