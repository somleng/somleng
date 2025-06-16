require "rails_helper"

RSpec.describe ExpireInProgressPhoneCalls do
  it "expires in progress phone calls" do
    account = create(:account)
    to_be_expired_phone_call = create(:phone_call, :initiated, account:, region: :hydrogen, initiated_at: 4.hours.ago)
    phone_call = create(:phone_call, :initiated, account:, region: :hydrogen, initiated_at: 3.hours.ago)
    account_session_limiter, global_session_limiter = build_session_limiters(account:, sessions: { hydrogen: 1 }, limit: 1)

    ExpireInProgressPhoneCalls.call(session_limiters: [ account_session_limiter, global_session_limiter ])

    expect(to_be_expired_phone_call.reload.session_timeout?).to be(true)
    expect(phone_call.reload.session_timeout?).to be(false)
    expect(account_session_limiter.session_count_for(:hydrogen, scope: account.id)).to eq(0)
    expect(global_session_limiter.session_count_for(:hydrogen)).to eq(0)
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
