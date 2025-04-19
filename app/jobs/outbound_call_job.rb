class OutboundCallJob < ApplicationJob
  class Handler
    attr_reader :account, :queue, :rate_limiters, :session_limiter

    def initialize(account, **options)
      @account = account
      @queue = options.fetch(:queue) { OutboundCallsQueue.new(account) }
      @rate_limiters = options.fetch(:rate_limiters) { build_rate_limiters }
      @session_limiter = options.fetch(:session_limiter) { PhoneCallSessionLimiter.new }
    end

    def perform
      return if queue.empty?

      queue.dequeue do |phone_call_id|
        phone_call = account.phone_calls.find(phone_call_id)

        rate_limit!
        session_limit!(phone_call.region.alias)

        ExecuteWorkflowJob.perform_later(InitiateOutboundCall.to_s, phone_call:)
      end
    rescue RateLimiter::RateLimitExceededError => e
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

    def rate_limit!
      rate_limiters.each(&:request!)
    end

    def session_limit!(region)
      session_limiter.add_session_to!(region)
    end

    def build_rate_limiters
      [ account, account.carrier ].each_with_object([]) do |owner, result|
        next if owner.calls_per_second.zero?

        result << RateLimiter.new(key: "#{owner.id}:outbound_calls", rate: owner.calls_per_second, window_size: 10.seconds)
      end
    end
  end

  def perform(...)
    Handler.new(...).perform
  end
end
