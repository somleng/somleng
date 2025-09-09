require "rails_helper"

RSpec.describe OutboundCallJob do
  it "initiates an outbound call" do
    account = create(:account)
    phone_call = create(:phone_call, account:, region: "helium")
    other_phone_call = create(:phone_call, account:)
    account_queue = build_queue(account)
    account_queue.enqueue(phone_call.id)
    account_queue.enqueue(other_phone_call.id)

    OutboundCallJob.perform_now(account, queue: account_queue)

    expect(ExecuteWorkflowJob).to have_been_enqueued.exactly(1).times.with(InitiateOutboundCall.to_s, phone_call:)
    expect(account_queue.peek).to eq(other_phone_call.id)
  end

  it "ignores calls which are not queued" do
    phone_call = create(:phone_call, :completed)
    account_queue = build_queue(phone_call.account)
    account_queue.enqueue(phone_call.id)

    OutboundCallJob.perform_now(phone_call.account, queue: account_queue)

    expect(ExecuteWorkflowJob).not_to have_been_enqueued
    expect(account_queue.peek).to be_nil
  end

  it "applies rate limits" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    phone_call = create(:phone_call, account:)
    account_queue = build_queue(account)
    account_rate_limiter = build_rate_limiter(key: account.id, rate: 1, window_size: 10.seconds)
    carrier_rate_limiter = build_rate_limiter(key: carrier.id, rate: 1, window_size: 10.seconds)
    account_queue.enqueue(phone_call.id)

    travel_to(Time.new(2025, 4, 18, 0, 0, 0)) do
      9.times { account_rate_limiter.request! }
      10.times { carrier_rate_limiter.request! }

      OutboundCallJob.perform_now(
        account,
        queue: account_queue,
        rate_limiters: [ account_rate_limiter, carrier_rate_limiter ]
      )

      expect(OutboundCallJob).to have_been_enqueued.with(
        account,
        wait_until: 10.seconds.from_now
      )
    end

    expect(account_queue.peek).to eq(phone_call.id)
  end

  it "applies session limits" do
    account = create(:account)
    phone_call = create(:phone_call, account:, region: "hydrogen")
    account_queue = build_queue(account)
    account_queue.enqueue(phone_call.id)
    account_session_limiter, global_session_limiter = build_session_limiters(account:, sessions: { hydrogen: 1 }, limit: 1)

    travel_to(Time.current) do
      OutboundCallJob.perform_now(account, queue: account_queue, session_limiters: [ account_session_limiter, global_session_limiter ])

      expect(OutboundCallJob).to have_been_enqueued.with(
        account,
        wait_until: 10.seconds.from_now
      )
    end

    expect(account_queue.peek).to eq(phone_call.id)
    expect(account_session_limiter.session_count_for(:hydrogen, scope: account.id)).to eq(1)
    expect(global_session_limiter.session_count_for(:hydrogen)).to eq(1)
  end

  def build_queue(account, **options)
    SimpleQueue.new(key: "queue:#{account.id}:outbound_calls", **options)
  end

  def build_rate_limiter(key:, **options)
    options = {
      rate: 1,
      window_size: 10.seconds,
      **options
    }

    RateLimiter.new(key: "#{key}:outbound_calls", **options)
  end

  def build_session_limiters(account:, sessions: {}, **)
    session_limiters = [ AccountCallSessionLimiter.new(**), GlobalCallSessionLimiter.new(**) ]

    sessions.each do |region, count|
      session_limiters.each do |session_limiter|
        count.times { session_limiter.add_session_to(region, scope: account.id) }
      end
    end

    session_limiters
  end
end
