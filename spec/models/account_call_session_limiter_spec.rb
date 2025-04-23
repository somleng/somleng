require "rails_helper"

RSpec.describe AccountCallSessionLimiter do
  it "adds a session" do
    account_id = SecureRandom.uuid
    session_limiter = AccountCallSessionLimiter.new

    session_limiter.add_session_to("hydrogen", scope: account_id)

    expect(session_limiter.session_count_for(:hydrogen, scope: account_id)).to eq(1)
    expect(session_limiter.session_count_for(:hydrogen, scope: SecureRandom.uuid)).to eq(0)

    session_limiter.add_session_to("helium", scope: account_id)

    expect(session_limiter.session_count_for(:helium, scope: account_id)).to eq(1)
  end

  it "removes a session" do
    account_id = SecureRandom.uuid
    session_limiter = AccountCallSessionLimiter.new

    session_limiter.add_session_to("hydrogen", scope: account_id)
    session_limiter.add_session_to("helium", scope: account_id)
    session_limiter.remove_session_from("hydrogen", scope: account_id)

    expect(session_limiter.session_count_for(:hydrogen, scope: account_id)).to eq(0)
    expect(session_limiter.session_count_for(:helium, scope: account_id)).to eq(1)
  end

  it "has limits which change with capacity" do
    SwitchCapacity.set_for(:hydrogen, capacity: 2)
    SwitchCapacity.set_for(:helium, capacity: 1)

    session_limiter = AccountCallSessionLimiter.new

    expect(session_limiter.session_counters.fetch(:hydrogen).limit).to eq(AppSettings.fetch(:account_call_sessions_limit) * 2)
    expect(session_limiter.session_counters.fetch(:helium).limit).to eq(AppSettings.fetch(:account_call_sessions_limit))
  end
end
