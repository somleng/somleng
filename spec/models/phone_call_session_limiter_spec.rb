require "rails_helper"

RSpec.describe PhoneCallSessionLimiter do
  it "adds a session" do
    session_limiter = build_limiter

    session_limiter.add_session!

    expect(session_limiter.sessions_count).to eq(1)
  end

  it "removes a session" do
    session_limiter = build_limiter

    session_limiter.add_session!
    session_limiter.add_session!
    session_limiter.remove_session!

    expect(session_limiter.sessions_count).to eq(1)
  end

  it "handles capacity" do
    session_limiter = build_limiter

    expect(session_limiter.current_capacity).to eq(1)

    session_limiter.current_capacity = 2

    expect(session_limiter.current_capacity).to eq(2)
  end

  it "handles limits" do
    sessions_limiter = build_limiter(sessions_limit: 1)

    sessions_limiter.add_session!

    expect(sessions_limiter.sessions_count).to eq(1)
    expect { sessions_limiter.add_session! }.to raise_error(PhoneCallSessionLimiter::SessionLimitExceededError)
  end

  it "handles multiple limiters" do
    hydrogen_limiter = build_limiter(key: "hydrogen")
    helium_limiter = build_limiter(key: "helium")

    hydrogen_limiter.add_session!
    helium_limiter.add_session!

    expect(hydrogen_limiter.sessions_count).to eq(1)
    expect(helium_limiter.sessions_count).to eq(1)
  end

  it "has a default limit" do
    expect(build_limiter.sessions_limit).to eq(100)
    expect(build_limiter(capacity: 2).sessions_limit).to eq(200)
  end

  def build_limiter(**options)
    options = {
      key: "hydrogen",
      **options
    }

    PhoneCallSessionLimiter.new(**options)
  end
end
