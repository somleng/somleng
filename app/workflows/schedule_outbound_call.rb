class ScheduleOutboundCall < ApplicationWorkflow
  attr_reader :phone_call, :rate_limiter, :queue

  def initialize(phone_call, **options)
    super()
    @phone_call = phone_call
    @queue = options.fetch(:queue) { InteractionQueue.new(phone_call.account, interaction_type: :outbound_calls) }
  end

  def call
    rate_limiter.request!
    queue.enqueue(phone_call.id)
    ExecuteWorkflowJob.perform_later(OutboundCallJob.to_s, account)
  rescue InteractionRateLimiter::RateLimitExceededError => e
    ScheduledJob.perform_later(
      ScheduleOutboundCall.to_s,
      phone_call,
      wait_until: e.seconds_remaining_in_current_window.seconds.from_now
    )
  end

  private

  def account
    phone_call.account
  end

  def build_rate_limiter
    InteractionRateLimiter.new(
      account,
      interaction_type: :phone_calls,
      identifier: ->(resource) { resource.id },
      limit: ->(resource) { resource.calls_per_second }
    )
  end
end
