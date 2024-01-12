require "rails_helper"

RSpec.describe CreateVerification do
  it "creates a new sms verification" do
    verification_service, phone_number, sms_gateway = create_verification_service(
      name: "Rocket Rides"
    )

    verification = CreateVerification.call(
      build_verification_params(
        verification_service:,
        phone_number:,
        to: "85512334667",
        channel: :sms,
        country_code: "KH",
        locale: "en"
      )
    )

    expect(verification).to have_attributes(
      delivery_attempts_count: 1,
      delivery_attempts: be_present,
      to: "85512334667",
      country_code: "KH",
      locale: "en"
    )
    expect(verification.delivery_attempts.first).to have_attributes(
      from: phone_number.number,
      to: "85512334667",
      channel: "sms",
      message: have_attributes(
        body: "Your Rocket Rides verification code is: #{verification.code}.",
        from: phone_number.number,
        to: "85512334667",
        internal: true,
        sms_gateway:,
        direction: "outbound"
      )
    )
    expect(OutboundMessageJob).to have_been_enqueued
  end

  it "creates a new call verification" do
    verification_service, phone_number, _sms_gateway, sip_trunk = create_verification_service(name: "Rocket Rides")

    verification = CreateVerification.call(
      build_verification_params(
        verification_service:,
        phone_number:,
        to: "85512334667",
        channel: :call
      )
    )

    expect(verification).to have_attributes(
      delivery_attempts_count: 1,
      delivery_attempts: be_present,
      to: "85512334667"
    )

    expect(verification.delivery_attempts.first).to have_attributes(
      from: phone_number.number,
      to: "85512334667",
      channel: "call",
      phone_call: have_attributes(
        twiml: include("Your Rocket Rides verification code is: #{verification.code.chars.join('. ')}."),
        internal: true,
        from: phone_number.number,
        to: "85512334667",
        direction: "outbound",
        sip_trunk:
      )
    )
    expect(ScheduledJob).to have_been_enqueued.with(
      OutboundCallJob.to_s, any_args
    )
  end

  it "creates a new sms verification" do
    verification_service, phone_number, = create_verification_service(
      name: "Rocket Rides"
    )

    verification = CreateVerification.call(
      build_verification_params(
        verification_service:,
        phone_number:,
        to: "66814822567",
        channel: :sms,
        country_code: "TH",
        locale: "th"
      )
    )

    expect(verification).to have_attributes(
      delivery_attempts_count: 1,
      delivery_attempts: be_present
    )
    expect(verification.delivery_attempts.first).to have_attributes(
      message: have_attributes(
        body: "รหัสยืนยันของคุณ Rocket Rides คือ: #{verification.code}."
      )
    )
  end

  it "updates an existing verification" do
    verification_service, phone_number, _sms_gateway = create_verification_service
    existing_verification = create(
      :verification,
      status: :pending,
      verification_service:,
      channel: :call
    )

    verification = CreateVerification.call(
      build_verification_params(
        verification: existing_verification,
        verification_service:,
        phone_number:,
        channel: :sms
      )
    )

    expect(verification).to eq(existing_verification)
    expect(verification.channel).to eq("sms")
  end

  def build_verification_params(verification_service:, phone_number:, **params)
    params.reverse_merge(
      verification_service:,
      account: verification_service.account,
      carrier: verification_service.carrier,
      channel: :sms,
      to: "85512334667",
      locale: "en",
      country_code: "KH",
      delivery_attempt: {
        from: phone_number.number
      }
    )
  end

  def create_verification_service(attributes = {})
    verification_service = create(:verification_service, attributes)
    phone_number = create(
      :phone_number, :assigned_to_account,
      account: verification_service.account
    )
    sms_gateway = create(:sms_gateway, carrier: verification_service.carrier)
    sip_trunk = create(:sip_trunk, carrier: verification_service.carrier)
    [verification_service, phone_number, sms_gateway, sip_trunk]
  end
end
