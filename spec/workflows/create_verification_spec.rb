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
        channel: :sms
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
      message: have_attributes(
        body: "Your Rocket Rides verification code is: #{verification.code}.",
        from: phone_number.number,
        to: "85512334667",
        internal: true,
        sms_gateway:
      )
    )
    expect(OutboundMessageJob).to have_been_enqueued
  end

  it "updates an existing verification" do
    verification_service, phone_number, _sms_gateway = create_verification_service
    existing_verification = create(
      :verification,
      status: :pending,
      verification_service:,
      channel: :sms
    )

    verification = CreateVerification.call(
      build_verification_params(
        verification: existing_verification,
        verification_service:,
        phone_number:,
        channel: :call
      )
    )

    expect(verification).to eq(existing_verification)
    expect(verification.channel).to eq("call")
  end

  def build_verification_params(verification_service:, phone_number:, **params)
    params.reverse_merge(
      verification_service:,
      account: verification_service.account,
      carrier: verification_service.carrier,
      channel: :sms,
      to: "85512334667",
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
    [verification_service, phone_number, sms_gateway]
  end
end
