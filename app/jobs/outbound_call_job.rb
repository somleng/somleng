class OutboundCallJob < ApplicationJob
  class SessionLimitExceededError < StandardError; end

  queue_as AppSettings.fetch(:aws_sqs_outbound_calls_queue_name)

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
      queue.dequeue do |phone_call_id|
        phone_call = PhoneCall.find(phone_call_id)

        rate_limit!
        session_limit!(phone_call)

        ExecuteWorkflowJob.perform_later(InitiateOutboundCall.to_s, phone_call:)

        phone_call.touch(:initiation_queued_at)
      end
    rescue RateLimiter::RateLimitExceededError => e
      logger.warn("Rate limit exceeded for account: #{account.id}. Rescheduling in #{e.seconds_remaining_in_current_window} seconds.")
      reschedule(wait_until: e.seconds_remaining_in_current_window.seconds.from_now)
    rescue SessionLimitExceededError => e
      logger.warn(e.message)
      reschedule(wait_until: 10.seconds.from_now)
    end

    private

    def rate_limit!
      rate_limiters.each(&:request!)
    end

    def session_limit!(phone_call)
      session_limiters.each do |limiter|
        next unless limiter.exceeds_limit?(phone_call.region.alias, scope: phone_call.account_id)

        raise SessionLimitExceededError, "Session limit exceeded for limiter: #{limiter.class} (Account ID: #{phone_call.account_id})"
      end
    end

    def reschedule(wait_until:)
      OutboundCallJob.perform_later(account, wait_until:)
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
