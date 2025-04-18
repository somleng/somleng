require "rails_helper"

RSpec.describe ScheduleOutboundCall do
  it "schedules an outbound call" do
    account = create(:account)
    phone_call = create(:phone_call, account:)
    account_queue = build_queue(account)

    ScheduleOutboundCall.call(phone_call, queue: account_queue)

    expect(account_queue.peek).to eq(phone_call.id)
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(OutboundCallJob.to_s, account)
  end

  it "applies a rate limit" do
    account = create(:account)
    phone_call = create(:phone_call, account:)
    account_queue = build_queue(account)

    rate_limiter = instance_double(InteractionRateLimiter)
    allow(rate_limiter).to receive(:request!).and_raise(
      InteractionRateLimiter::RateLimitExceededError.new(
        "Rate limit exceeded",
        seconds_remaining_in_current_window: 5
      )
    )

    travel_to(Time.current) do
      ScheduleOutboundCall.call(phone_call, rate_limiter:, queue: account_queue)

      expect(ScheduledJob).to have_been_enqueued.with(
        ScheduleOutboundCall.to_s,
        phone_call,
        wait_until: 5.seconds.from_now
      )
      expect(account_queue.peek).to be_nil
    end
  end

  def build_queue(account, **options)
    options = {
      interaction_type: :outbound_calls,
      **options
    }
    InteractionQueue.new(account, **options)
  end
end
