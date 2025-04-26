require "rails_helper"

RSpec.describe UpdatePhoneCallStatus do
  it "handles ringing events" do
    account = create(:account)
    phone_call = create(:phone_call, :initiated, account:, region: :hydrogen)
    account_session_limiter, global_session_limiter = build_session_limiters(account:, sessions: { hydrogen: 2 })

    UpdatePhoneCallStatus.call(
      phone_call,
      {
        event_type: "ringing",
        answer_epoch: "0",
        sip_term_status: ""
      }
    )

    expect(phone_call.status).to eq("ringing")
    expect(account_session_limiter.session_count_for(:hydrogen, scope: account.id)).to eq(2)
    expect(global_session_limiter.session_count_for(:hydrogen)).to eq(2)
  end

  it "handles answered events" do
    account = create(:account)
    phone_call = create(:phone_call, :initiated, account:, region: :hydrogen)
    account_session_limiter, global_session_limiter = build_session_limiters(account:, sessions: { hydrogen: 2 })

    UpdatePhoneCallStatus.call(
      phone_call,
      {
        event_type: "answered",
        answer_epoch: 0,
        sip_term_status: ""
      }
    )

    expect(phone_call.status).to eq("answered")
    expect(account_session_limiter.session_count_for(:hydrogen, scope: account.id)).to eq(2)
    expect(global_session_limiter.session_count_for(:hydrogen)).to eq(2)
  end

  it "handles completed events" do
    account = create(:account)
    phone_call = create(:phone_call, :outbound, :answered, account:, region: :hydrogen, to: "855715400235")
    account_session_limiter, global_session_limiter = build_session_limiters(account:, sessions: { hydrogen: 2 })

    UpdatePhoneCallStatus.call(
      phone_call,
      {
        event_type: "completed",
        sip_term_status: "200",
        answer_epoch: "1585814727"
      }
    )

    expect(phone_call.status).to eq("completed")
    expect(phone_call.reload.interaction).to be_present
    expect(account_session_limiter.session_count_for(:hydrogen, scope: account.id)).to eq(1)
    expect(global_session_limiter.session_count_for(:hydrogen)).to eq(1)
  end

  it "handles events received out of order" do
    phone_call = create(:phone_call, :completed)

    UpdatePhoneCallStatus.call(
      phone_call,
      {
        event_type: "answered",
        answer_epoch: 0,
        sip_term_status: ""
      }
    )

    expect(phone_call.status).to eq("completed")
  end

  it "handles completed events with not answered" do
    phone_call = create(:phone_call, :ringing)

    UpdatePhoneCallStatus.call(
      phone_call,
      {
        event_type: "completed",
        answer_epoch: "0",
        sip_term_status: "487"
      }
    )

    expect(phone_call.status).to eq("not_answered")
  end

  it "handles completed events with canceled" do
    phone_call = create(:phone_call, :ringing)

    UpdatePhoneCallStatus.call(
      phone_call,
      {
        event_type: "completed",
        answer_epoch: nil,
        sip_term_status: nil,
        sip_invite_failure_status: "487"
      }
    )

    expect(phone_call.status).to eq("canceled")
  end

  it "handles completed events with busy" do
    phone_call = create(:phone_call, :ringing)

    UpdatePhoneCallStatus.call(
      phone_call,
      {
        event_type: "completed",
        answer_epoch: "0",
        sip_term_status: "486"
      }
    )

    expect(phone_call.status).to eq("busy")
  end

  it "handles invalid state transitions" do
    phone_call = create(:phone_call, status: :session_timeout)

    expect {
      UpdatePhoneCallStatus.call(
        phone_call,
        {
          event_type: "completed",
          answer_epoch: "1585814727",
          sip_term_status: "200"
        }
      )
    }.to raise_error(UpdatePhoneCallStatus::InvalidStateTransitionError)
  end

  it "handles repeated events" do
    phone_call = create(:phone_call, :initiated, :failed)

    UpdatePhoneCallStatus.call(
      phone_call,
      {
        event_type: "completed",
        answer_epoch: "0",
        sip_term_status: "404"
      }
    )

    expect(phone_call.status).to eq("failed")
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
