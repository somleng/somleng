class OutboundCallJob < ApplicationJob
  class Handler
    attr_reader :account, :queue, :rate_limiter

    def initialize(account, **options)
      @account = account
      @queue = options.fetch(:queue) { InteractionQueue.new(account, interaction_type: :outbound_calls) }
      @rate_limiter = options.fetch(:rate_limiter) { build_rate_limiter }
      @session_limiter = options.fetch(:session_limiter, nil)
    end

    def perform
      return if queue.empty?

      queue.dequeue do |phone_call_id|
        phone_call = PhoneCall.find(phone_call_id)

        rate_limiter.request!
        session_limiter ||= build_session_limiter(phone_call.sip_trunk.region.alias)
        session_limiter.add_session!

        ExecuteWorkflowJob.perform_later(InitiateOutboundCall.to_s, phone_call:)
      end
    rescue InteractionRateLimiter::RateLimitExceededError => e
      OutboundCallJob.perform_later(
        account,
        wait_until: e.seconds_remaining_in_current_window.seconds.from_now
      )
    rescue PhoneCallSessionLimiter::SessionLimitExceededError
      OutboundCallJob.perform_later(
        account,
        wait_until: 10.seconds.from_now
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

    def build_session_limiter(region)
      @session_limiter ||= PhoneCallSessionLimiter.new(key: region)
    end
  end

  def perform(...)
    Handler.new(...).perform
  end
end
