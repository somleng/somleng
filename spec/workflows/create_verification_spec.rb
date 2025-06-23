require "rails_helper"

RSpec.describe CreateVerification do
  it "creates a new SMS verification" do
    verification_service, sms_gateway = create_verification_service(
      name: "Rocket Rides"
    )

    verification = CreateVerification.call(
      build_verification_params(
        verification_service:,
        sender: sms_gateway.default_sender,
        to: "85512334667",
        channel: :sms,
        country_code: "KH",
        locale: "en"
      )
    )

    expect(verification).to have_attributes(
      delivery_attempts_count: 1,
      delivery_attempts: be_present,
      to: have_attributes(value: "85512334667"),
      country_code: "KH",
      locale: "en"
    )
    expect(verification.delivery_attempts.first).to have_attributes(
      from: sms_gateway.default_sender,
      to: have_attributes(value: "85512334667"),
      channel: "sms",
      message: have_attributes(
        body: "Your Rocket Rides verification code is: #{verification.code}.",
        from: sms_gateway.default_sender,
        to: have_attributes(value: "85512334667"),
        internal: true,
        sms_gateway:,
        direction: "outbound"
      )
    )
    expect(OutboundMessageJob).to have_been_enqueued
  end

  it "creates a new call verification" do
    verification_service, _sms_gateway, sip_trunk = create_verification_service(name: "Rocket Rides")

    verification = CreateVerification.call(
      build_verification_params(
        verification_service:,
        sender: sip_trunk.default_sender,
        to: "85512334667",
        channel: :call
      )
    )

    expect(verification).to have_attributes(
      delivery_attempts_count: 1,
      delivery_attempts: be_present,
      to: have_attributes(value: "85512334667")
    )

    expect(verification.delivery_attempts.first).to have_attributes(
      from: sip_trunk.default_sender,
      to: have_attributes(value: "85512334667"),
      channel: "call",
      phone_call: have_attributes(
        twiml: include("Your Rocket Rides verification code is: #{verification.code.chars.join(', ')}."),
        internal: true,
        from: sip_trunk.default_sender,
        to: have_attributes(value: "85512334667"),
        direction: "outbound_api",
        sip_trunk:,
      )
    )
    expect(OutboundCallJob).to have_been_enqueued
  end

  it "handles Thai SMS verifications" do
    verification_service, sms_gateway, = create_verification_service(
      name: "Rocket Rides"
    )

    verification = CreateVerification.call(
      build_verification_params(
        verification_service:,
        sender: sms_gateway.default_sender,
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

  it "handles Khmer SMS verifications" do
    verification_service, sms_gateway, = create_verification_service(
      name: "Rocket Rides"
    )

    verification = CreateVerification.call(
      build_verification_params(
        verification_service:,
        sender: sms_gateway.default_sender,
        channel: :sms,
        locale: "km"
      )
    )

    expect(verification.delivery_attempts.first).to have_attributes(
      message: have_attributes(
        body: "លេខកូដផ្ទៀងផ្ទាត់ Rocket Rides របស់អ្នកគឺ៖ #{verification.code}."
      )
    )
  end

  it "updates an existing verification" do
    verification_service, sms_gateway, = create_verification_service
    existing_verification = create(
      :verification,
      status: :pending,
      verification_service:,
      channel: :call,
      locale: :en
    )

    verification = CreateVerification.call(
      build_verification_params(
        verification: existing_verification,
        verification_service:,
        sender: sms_gateway.default_sender,
        channel: :sms,
        locale: :de
      )
    )

    expect(verification).to eq(existing_verification)
    expect(verification).to have_attributes(
      channel: "sms",
      locale: "de"
    )
  end

  def build_verification_params(verification_service:, sender:, **params)
    params.reverse_merge(
      verification_service:,
      account: verification_service.account,
      carrier: verification_service.carrier,
      channel: :sms,
      to: "85512334667",
      locale: "en",
      country_code: "KH",
      delivery_attempt: {
        from: sender
      }
    )
  end

  def create_verification_service(attributes = {})
    verification_service = create(:verification_service, attributes)
    sms_gateway = create(:sms_gateway, carrier: verification_service.carrier, default_sender: generate(:phone_number))
    sip_trunk = create(:sip_trunk, carrier: verification_service.carrier, default_sender: generate(:phone_number))
    [ verification_service, sms_gateway, sip_trunk ]
  end
end
