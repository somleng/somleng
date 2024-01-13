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

  it "Show a verification service", :js do
    verification_service = create(
      :verification_service,
      name: "Rocket Rides",
      code_length: 6
    )
    user = create(:user, :carrier, carrier: verification_service.carrier)

    carrier_sign_in(user)
    visit dashboard_verification_service_path(verification_service)

    expect(page).to have_content(/Your Rocket Rides verification code is: \d{6}\./)

    choices_select("German", from: "locale_preview")

    expect(page).to have_content(/Dein Rocket Rides Sicherheitscode lautet: \d{6}./)
  end

  it "Create a verification service" do
    carrier = create(:carrier)
    create(:account, carrier:, name: "Rocket Rides")
    user = create(:user, :carrier, :admin, carrier:)

    carrier_sign_in(user)
    visit dashboard_verification_services_path
    click_on("New")
    fill_in("Friendly name", with: "Ride Service")
    select("4 digits", from: "Code length")
    choices_select("Rocket Rides", from: "Account")
    click_on("Create Verification service")

    expect(page).to have_content("Verification service was successfully created")
    expect(page).to have_content("Ride Service")
    expect(page).to have_content("Rocket Rides")
  end
end
