class OutboundCallJob < ApplicationJob
  class Handler
    attr_reader :account, :queue, :rate_limiters, :session_limiters, :logger

    def initialize(account, **options)
      @account = account
      @logger = options.fetch(:logger) { Rails.logger }
      @queue = options.fetch(:queue) { OutboundCallsQueue.new(account) }
      @rate_limiters = options.fetch(:rate_limiters) { build_rate_limiters }
      @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new(logger:), GlobalCallSessionLimiter.new(logger:) ] }
    end

    def perform
      return if queue.empty?

      queue.dequeue do |phone_call_id|
        phone_call = account.phone_calls.find(phone_call_id)

        rate_limit!
        session_limit!(phone_call)

        ExecuteWorkflowJob.perform_later(InitiateOutboundCall.to_s, phone_call:)
      end
    rescue RateLimiter::RateLimitExceededError => e
      OutboundCallJob.perform_later(
        account,
        wait_until: e.seconds_remaining_in_current_window.seconds.from_now
      )
    rescue CallSessionLimiter::SessionLimitExceededError
      OutboundCallJob.perform_later(
        account,
        wait_until: 10.seconds.from_now
      )
    end

    private

    def rate_limit!
      rate_limiters.each(&:request!)
    end

    def session_limit!(phone_call)
      session_limiters.each { _1.add_session_to!(phone_call.region.alias, scope: phone_call.account_id) }
    end

    def build_rate_limiters
      [ account, account.carrier ].each_with_object([]) do |owner, result|
        next if owner.calls_per_second.zero?

        result << RateLimiter.new(key: "#{owner.id}:outbound_calls", rate: owner.calls_per_second, window_size: 10.seconds)
      end
    end
  end

  def perform(*, **options)
    Handler.new(*, logger:, **options).perform
  end
end
