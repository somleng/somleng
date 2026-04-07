require "rails_helper"

RSpec.describe ExpireInProgressPhoneCalls do
  it "expires in progress phone calls" do
    account = create(:account)
    to_be_expired_phone_call1 = create(:phone_call, :initiated, account:, region: :hydrogen, last_heartbeat_at: 1.minute.ago)
    to_be_expired_phone_call2 = create(:phone_call, :initiated, account:, region: :helium, last_heartbeat_at: nil, initiated_at: 2.hour.ago)
    phone_call = create(:phone_call, :initiated, account:, region: :hydrogen, last_heartbeat_at: 30.seconds.ago)
    account_session_limiter, global_session_limiter = build_session_limiters(account:, sessions: { hydrogen: 1, helium: 1 }, limit: 2)

    ExpireInProgressPhoneCalls.call(session_limiters: [ account_session_limiter, global_session_limiter ])

    expect(to_be_expired_phone_call1.reload.session_timeout?).to be(true)
    expect(to_be_expired_phone_call2.reload.session_timeout?).to be(true)
    expect(phone_call.reload.session_timeout?).to be(false)
    expect(account_session_limiter.session_count_for(:hydrogen, scope: account.id)).to eq(0)
    expect(global_session_limiter.session_count_for(:hydrogen)).to eq(0)
    expect(global_session_limiter.session_count_for(:helium)).to eq(0)
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
