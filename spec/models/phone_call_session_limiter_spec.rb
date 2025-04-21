require "rails_helper"

RSpec.describe PhoneCallSessionLimiter do
  it "adds a session" do
    session_limiter = PhoneCallSessionLimiter.new(expiry: 1.second)

    session_limiter.add_session_to("hydrogen")
    expect(session_limiter.session_counter_for(:hydrogen).count).to eq(1)

    session_limiter.add_session_to("helium")
    expect(session_limiter.session_counter_for(:helium).count).to eq(1)

    sleep 1

    expect(session_limiter.session_counter_for(:hydrogen).count).to eq(0)
    expect(session_limiter.session_counter_for(:helium).count).to eq(0)
  end

  it "removes a session" do
    session_limiter = PhoneCallSessionLimiter.new(expiry: 1.second)

    session_limiter.add_session_to("hydrogen")
    session_limiter.add_session_to("helium")
    session_limiter.remove_session_from("hydrogen")

    expect(session_limiter.session_counter_for(:hydrogen).count).to eq(0)
    expect(session_limiter.session_counter_for(:helium).count).to eq(1)

    sleep 1

    expect(session_limiter.session_counter_for(:helium).count).to eq(0)
  end

  it "handles limits" do
    session_limiter = PhoneCallSessionLimiter.new(
      session_counters: {
        hydrogen: SimpleCounter.new(key: "phone_call_sessions:hydrogen", limit: 1)
      }
    )

    session_limiter.add_session_to!(:hydrogen)
    expect { session_limiter.add_session_to!(:hydrogen) }.to raise_error(PhoneCallSessionLimiter::SessionLimitExceededError)
    expect(session_limiter.session_counter_for(:hydrogen).count).to eq(1)
    session_limiter.add_session_to(:hydrogen)
    expect(session_limiter.session_counter_for(:hydrogen).count).to eq(2)
  end

  it "has limits which change with capacity" do
    other_session_limiter = PhoneCallSessionLimiter.new
    other_session_limiter.set_capacity_for(:hydrogen, capacity: 2)
    other_session_limiter.set_capacity_for(:helium, capacity: 1)

    session_limiter = PhoneCallSessionLimiter.new

    expect(session_limiter.session_counter_for(:hydrogen).limit).to eq(200)
    expect(session_limiter.session_counter_for(:helium).limit).to eq(100)
  end
end
