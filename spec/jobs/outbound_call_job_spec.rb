require "rails_helper"

RSpec.describe OutboundCallJob do
  it "initiates an outbound call" do
    account = create(:account)
    phone_call = create(:phone_call, account:)
    other_phone_call = create(:phone_call, account:)
    account_queue = build_queue(account)
    account_queue.enqueue(phone_call.id)
    account_queue.enqueue(other_phone_call.id)

    OutboundCallJob.perform_now(account, queue: account_queue)

    expect(ExecuteWorkflowJob).to have_been_enqueued.exactly(1).times.with(InitiateOutboundCall.to_s, phone_call:)
    expect(account_queue.peek).to eq(other_phone_call.id)
  end

  it "applies a rate limit" do
    account = create(:account)
    phone_call = create(:phone_call, account:)
    account_queue = build_queue(account)
    account_queue.enqueue(phone_call.id)
    rate_limiter = instance_double(InteractionRateLimiter)
    allow(rate_limiter).to receive(:request!).and_raise(
      InteractionRateLimiter::RateLimitExceededError.new(
        "Rate limit exceeded",
        seconds_remaining_in_current_window: 5
      )
    )

    travel_to(Time.current) do
      OutboundCallJob.perform_now(account, queue: account_queue, rate_limiter:)

      expect(OutboundCallJob).to have_been_enqueued.with(
        account,
        wait_until: 5.seconds.from_now
      )
      expect(account_queue.peek).to eq(phone_call.id)
    end
  end

  it "applies session limits" do
    account = create(:account)
    phone_call = create(:phone_call, account:)
    account_queue = build_queue(account)
    account_queue.enqueue(phone_call.id)
    session_limiter = instance_double(PhoneCallSessionLimiter)
    allow(session_limiter).to receive(:add_session!).and_raise(
      PhoneCallSessionLimiter::SessionLimitExceededError
    )

    travel_to(Time.current) do
      OutboundCallJob.perform_now(account, queue: account_queue, session_limiter:)

      expect(OutboundCallJob).to have_been_enqueued.with(
        account,
        wait_until: 10.seconds.from_now
      )
      expect(account_queue.peek).to eq(phone_call.id)
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
