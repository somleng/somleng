require "rails_helper"

RSpec.describe "Verification Services" do
  it "List and filter verification services" do
    verification_service = create(:verification_service, name: "Rocket Rides")
    create(:verification_service, account: verification_service.account, name: "Foobar")
    user = create(:user, :carrier, carrier: verification_service.carrier)

    carrier_sign_in(user)

    visit(dashboard_verification_services_path(filter: { name: "Rocket Rides" }))

    expect(page).to have_content("Rocket Rides")
    expect(page).to have_no_content("Foobar")
  end

  it "Shows a verification service" do
    verification_service = create(
      :verification_service,
      name: "Rocket Rides",
      code_length: 6
    )
    user = create(:user, :carrier, carrier: verification_service.carrier)

    carrier_sign_in(user)
    visit dashboard_verification_service_path(verification_service)

    expect(page).to have_content(/Your Rocket Rides verification code is: \d{6}\./)
  end
end
