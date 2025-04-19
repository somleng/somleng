require "rails_helper"

RSpec.describe CreateInboundPhoneCall do
  it "creates an inbound phone call" do
    phone_call = CreateInboundPhoneCall.call(build_params)

    expect(phone_call).to have_attributes(
      initiating_at: be_present,
      initiated_at: be_present,
      status: "initiated"
    )
  end

  it "adds a session" do
    session_limiter = PhoneCallSessionLimiter.new

    CreateInboundPhoneCall.call(build_params(region: "helium"), session_limiter:)

    expect(session_limiter.session_counter_for(:helium)).to have_attributes(
      count: 1
    )
  end

  def build_params(**options)
    carrier = options.fetch(:carrier) { create(:carrier) }
    sip_trunk = options.fetch(:sip_trunk) { create(:sip_trunk, carrier:) }
    account = options.fetch(:account) { create(:account, carrier:) }
    incoming_phone_number = options.fetch(:incoming_phone_number) { create(:incoming_phone_number, account:) }

    {
      direction: "inbound",
      external_id: "external-id",
      voice_url: "https://demo.twilio.com/docs/voice.xml",
      voice_method: "GET",
      status_callback_url: "https://example.com/status-callback",
      status_callback_method: "POST",
      call_service_host: "10.10.1.13",
      region: "hydrogen",
      to: "12513095500",
      from: "855716100230",
      carrier:,
      sip_trunk:,
      incoming_phone_number:,
      account:,
      **options
    }
  end
end
