require "rails_helper"

RSpec.describe GlobalCallSessionLimiter do
  it "adds a session" do
    session_limiter = GlobalCallSessionLimiter.new(expiry: 1.second)

    session_limiter.add_session_to("hydrogen")
    expect(session_limiter.session_count_for(:hydrogen)).to eq(1)

    session_limiter.add_session_to("helium")
    expect(session_limiter.session_count_for(:helium)).to eq(1)

    sleep 1

    expect(session_limiter.session_count_for(:hydrogen)).to eq(0)
    expect(session_limiter.session_count_for(:helium)).to eq(0)
  end

  it "removes a session" do
    session_limiter = GlobalCallSessionLimiter.new(expiry: 1.second)

    session_limiter.add_session_to("hydrogen")
    session_limiter.add_session_to("helium")
    session_limiter.remove_session_from("hydrogen")

    expect(session_limiter.session_count_for(:hydrogen)).to eq(0)
    expect(session_limiter.session_count_for(:helium)).to eq(1)

    sleep 1

    expect(session_limiter.session_count_for(:helium)).to eq(0)
  end

  it "handles limits" do
    session_limiter = GlobalCallSessionLimiter.new(limit: 1)

    session_limiter.add_session_to!(:hydrogen)
    expect { session_limiter.add_session_to!(:hydrogen) }.to raise_error(CallSessionLimiter::SessionLimitExceededError)
    expect(session_limiter.session_count_for(:hydrogen)).to eq(1)
    session_limiter.add_session_to(:hydrogen)
    expect(session_limiter.session_count_for(:hydrogen)).to eq(2)
  end

  it "has limits which change with capacity" do
    CallServiceCapacity.set_for(:hydrogen, capacity: 2)
    CallServiceCapacity.set_for(:helium, capacity: 1)

    session_limiter = GlobalCallSessionLimiter.new

    expect(session_limiter.session_counters.fetch(:hydrogen).limit).to eq(AppSettings.fetch(:global_call_sessions_limit) * 2)
    expect(session_limiter.session_counters.fetch(:helium).limit).to eq(AppSettings.fetch(:global_call_sessions_limit))
  end
end
