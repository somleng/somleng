require "rails_helper"

RSpec.describe CreateVerification do
  it "creates a new SMS verification" do
    verification_service = create(:verification_service, name: "Rocket Rides")
    sms_gateway = create(
      :sms_gateway,
      :fallback,
      sender_id: "VERIFY",
      carrier: verification_service.carrier
    )

    verification = CreateVerification.call(
      build_verification_params(
        verification_service:,
        originator_id: sms_gateway.sender_id,
        to: "85512334667",
        channel: :sms,
        country_code: "KH",
        locale: "en"
      )
    )

    expect(verification).to have_attributes(
      to: have_attributes(value: "85512334667"),
      country_code: "KH",
      locale: "en",
      delivery_attempts: contain_exactly(
        have_attributes(
          from: "VERIFY",
          to: have_attributes(value: "85512334667"),
          channel: "sms",
          message: have_attributes(
            body: "Your Rocket Rides verification code is: #{verification.code}.",
            sender_id: "VERIFY",
            from: nil,
            to: have_attributes(value: "85512334667"),
            internal: true,
            sms_gateway:,
            direction: "outbound"
          )
        )
      )
    )
    expect(OutboundMessageJob).to have_been_enqueued
  end

  it "creates a new call verification" do
    verification_service = create(:verification_service, name: "Rocket Rides")
    sip_trunk = create(:sip_trunk, :fallback, carrier: verification_service.carrier)

    verification = CreateVerification.call(
      build_verification_params(
        verification_service:,
        originator_id: sip_trunk.caller_id,
        to: "85512334667",
        channel: :call
      )
    )

    expect(verification).to have_attributes(
      delivery_attempts_count: 1,
      to: have_attributes(value: "85512334667"),
      delivery_attempts: contain_exactly(
        have_attributes(
          from: sip_trunk.caller_id,
          to: have_attributes(value: "85512334667"),
          channel: "call",
          phone_call: have_attributes(
            twiml: include("Your Rocket Rides verification code is: #{verification.code.chars.join(', ')}."),
            internal: true,
            from: sip_trunk.caller_id,
            to: have_attributes(value: "85512334667"),
            direction: "outbound_api",
            sip_trunk:,
          )
        )
      )
    )
    expect(OutboundCallJob).to have_been_enqueued
  end

  it "handles Khmer SMS verifications" do
    verification_service = create(:verification_service, name: "Rocket Rides")
    sms_gateway = create(:sms_gateway, :fallback, carrier: verification_service.carrier)

    verification = CreateVerification.call(
      build_verification_params(
        verification_service:,
        originator_id: sms_gateway.sender_id,
        channel: :sms,
        locale: "km"
      )
    )

    expect(verification).to have_attributes(
      delivery_attempts: contain_exactly(
        have_attributes(
          message: have_attributes(
            body: "លេខកូដផ្ទៀងផ្ទាត់ Rocket Rides របស់អ្នកគឺ៖ #{verification.code}."
          )
        )
      )
    )
  end

  it "updates an existing verification" do
    verification_service = create(:verification_service)
    sms_gateway = create(:sms_gateway, :fallback, carrier: verification_service.carrier)
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
        originator_id: sms_gateway.sender_id,
        channel: :sms,
        locale: :de
      )
    )

    expect(verification).to have_attributes(
      id: existing_verification.id,
      channel: "sms",
      locale: "de"
    )
  end

  def build_verification_params(verification_service:, originator_id:, **params)
    {
      verification_service:,
      account: verification_service.account,
      carrier: verification_service.carrier,
      channel: :sms,
      to: "85512334667",
      locale: "en",
      country_code: "KH",
      delivery_attempt: {
        from: originator_id
      },
      **params
    }
  end
end
