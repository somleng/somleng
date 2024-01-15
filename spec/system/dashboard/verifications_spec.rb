require "rails_helper"

RSpec.describe "Verifications" do
  it "List and filter verifications" do
    verification_service = create(:verification_service)
    pending_verification = create(:verification, :pending, verification_service:)
    expired_verification = create(:verification, :expired, verification_service:)
    approved_verification = create(:verification, :approved, verification_service:)
    other_verification = create(
      :verification,
      verification_service: create(
        :verification_service,
        account: verification_service.account,
        carrier: verification_service.carrier
      )
    )
    user = create(:user, :carrier, carrier: verification_service.carrier)

    carrier_sign_in(user)
    visit(
      dashboard_verifications_path(
        filter: { verification_service_id: verification_service.id }
      )
    )

    expect(page).to have_content(pending_verification.id)
    expect(page).to have_content(expired_verification.id)
    expect(page).to have_content(approved_verification.id)
    expect(page).to have_no_content(other_verification.id)
  end

  it "shows a verification" do
    account = create(:account, name: "Rocket Rides")
    verification_service = create(:verification_service, name: "Ride Service", account:)
    verification = create(
      :verification, :approved,
      verification_service:, to: "66814822567",
      country_code: "TH"
    )
    _delivery_attempt = create(:verification_delivery_attempt, :sms, verification:)
    _failed_verification_attempt = create(:verification_attempt, verification:)
    _successful_verification_attempt = create(:verification_attempt, :successful, verification:)
    user = create(:user, :carrier, carrier: verification.carrier)

    carrier_sign_in(user)
    visit(dashboard_verification_path(verification))

    expect(page).to have_content(verification.id)
    expect(page).to have_content("Approved")
    expect(page).to have_link(
      "Ride Service",
      href: dashboard_verification_service_path(verification.verification_service)
    )
    expect(page).to have_link(
      "Rocket Rides",
      href: dashboard_account_path(verification.account)
    )
    expect(page).to have_content("Thailand")

    within("#delivery-attempt-1") do
      expect(page).to have_content("SMS")
    end

    within("#verification-attempt-1") do
      expect(page).to have_content("Failed")
    end

    within("#verification-attempt-2") do
      expect(page).to have_content("Successful")
    end
  end
end
