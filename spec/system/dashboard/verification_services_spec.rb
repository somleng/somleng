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
    expect(page).to have_link(
      "View verifications",
      href: dashboard_verifications_path(filter: { verification_service_id: verification_service.id })
    )

    enhanced_select("German", from: "locale_preview", exact: true)

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
    enhanced_select("Rocket Rides", from: "Account")
    click_on("Create Verification service")

    expect(page).to have_content("Verification service was successfully created")
    expect(page).to have_content("Ride Service")
    expect(page).to have_content("Rocket Rides")
    expect(page).to have_content("4 digits")
  end

  it "Handles validations" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_verification_service_path
    click_on("Create Verification service")

    expect(page).to have_content("can't be blank")
  end

  it "Create verifiction service as an account admin" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    user = create(:user, :with_account_membership, account_role: :admin, account:, carrier:)

    carrier_sign_in(user)
    visit new_dashboard_verification_service_path

    fill_in("Friendly name", with: "Ride Service")
    select("4 digits", from: "Code length")
    click_on("Create Verification service")

    expect(page).to have_content("Verification service was successfully created")
  end

  it "Update a verification service" do
    carrier = create(:carrier)
    user = create(:user, :carrier, :admin, carrier:)
    verification_service = create(:verification_service, carrier:)

    carrier_sign_in(user)
    visit dashboard_verification_service_path(verification_service)
    click_on("Edit")
    fill_in("Friendly name", with: "Ride Service")
    select("8 digits", from: "Code length")
    click_on("Update Verification service")

    expect(page).to have_content("Verification service was successfully updated")
    expect(page).to have_content("Ride Service")
    expect(page).to have_content("8 digits")
  end

  it "Delete a verification service" do
    carrier = create(:carrier)
    create(:account, carrier:, name: "Rocket Rides")
    user = create(:user, :carrier, :admin, carrier:)
    verification_service = create(:verification_service, carrier:, name: "Ride Service")
    create(:verification, verification_service:)

    carrier_sign_in(user)
    visit dashboard_verification_service_path(verification_service)
    click_on("Delete")

    expect(page).to have_content("Verification service was successfully destroyed")
    expect(page).to have_no_content("Ride Service")
  end
end
