require "rails_helper"

RSpec.describe CreatePhoneCallsFromOutboundDial do
  it "creates outbound phone calls" do
    sip_trunk = create(:sip_trunk)
    account = create(:account, carrier: sip_trunk.carrier)
    parent_call = create(:phone_call, :outbound, :answered, account:, sip_trunk:, to: "855715100210", region: "hydrogen")
    account_session_limiter = AccountCallSessionLimiter.new
    global_session_limiter = GlobalCallSessionLimiter.new

    new_phone_calls = CreatePhoneCallsFromOutboundDial.call(
      {
        parent_call:,
        from: "855715100210",
        incoming_phone_number: nil,
        destinations: [
          { destination: "855715100230", sip_trunk: },
          { destination: "855715100231", sip_trunk: }
        ]
      },
      session_limiters: [ account_session_limiter, global_session_limiter ]
    )

    expect(new_phone_calls.count).to eq(2)
    expect(new_phone_calls.first).to have_attributes(
      parent_call:,
      sip_trunk:,
      to: have_attributes(value: "855715100230"),
      from: have_attributes(value: "855715100210"),
      direction: "outbound_dial",
      status: "initiated"
    )
    expect(account_session_limiter.session_count_for(:hydrogen, scope: account.id)).to eq(2)
    expect(global_session_limiter.session_count_for(:hydrogen)).to eq(2)
  end
end
