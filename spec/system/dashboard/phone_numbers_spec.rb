require "rails_helper"

RSpec.describe "Phone Numbers" do
  it "List, filter and bulk delete phone numbers" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    common_attributes = {
      carrier:,
      iso_country_code: "US",
      type: :local,
      created_at: Time.utc(2024, 4, 27),
      visibility: :public,
      iso_region_code: "AR",
      locality: "Little Rock",
      lata: "528",
      rate_center: "LITTLEROCK"
    }

    create(:phone_number, common_attributes.merge(number: "12013095500"))
    create(:phone_number, common_attributes.merge(number: "12513095500"))
    create(:phone_number, common_attributes.merge(number: "12513095501", created_at: Time.utc(2021, 10, 10)))
    create(:phone_number, common_attributes.merge(number: "12513095502", type: :mobile))
    create(:phone_number, common_attributes.merge(number: "12513095503", visibility: :private))
    create(:phone_number, common_attributes.merge(number: "12513095504", iso_country_code: "CA", iso_region_code: "ON"))
    create(:phone_number, common_attributes.merge(number: "12513095505", iso_region_code: "CA"))
    create(:phone_number, common_attributes.merge(number: "12513095506", locality: "Bentonville"))
    create(:phone_number, common_attributes.merge(number: "12513095507", lata: "528", rate_center: "ABERDEEN"))

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path(
      filter: {
        country: "US",
        type: "local",
        from_date: "27/04/2024",
        to_date: "27/04/2024",
        assigned: false,
        visibility: "public",
        area_code: "251",
        region: "AR",
        locality: "Little Rock",
        lata: "528",
        rate_center: "LITTLEROCK"
      }
    )

    expect(page).to have_text("+1 (251) 309-5500")
    expect(page).to have_no_text("+1 (201) 309-5500")
    expect(page).to have_no_text("+1 (251) 309-5501")
    expect(page).to have_no_text("+1 (251) 309-5502")
    expect(page).to have_no_text("+1 (251) 309-5503")
    expect(page).to have_no_text("+1 (251) 309-5504")
    expect(page).to have_no_text("+1 (251) 309-5505")
    expect(page).to have_no_text("+1 (251) 309-5506")
    expect(page).to have_no_text("+1 (251) 309-5507")

    click_on("Delete")

    expect(page).to have_text("Phone numbers were successfully destroyed")
    expect(page).to have_no_text("+1 (251) 309-5500")
    expect(page).to have_no_selector(:link_or_button, "Delete")
  end

  it "Export phone numbers" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    create(
      :phone_number,
      carrier:,
      number: "12513095500",
      price: Money.from_amount(1.15, "USD"),
      visibility: :public,
      type: :local,
      iso_country_code: "US",
      iso_region_code: "AR",
      locality: "Little Rock",
      lata: "528",
      rate_center: "LITTLEROCK",
      latitude: "34.748463",
      longitude: "-92.284434",
    )
    create(:phone_number, carrier:, number: "12513095501", visibility: :private)

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path(
      filter: {
        visibility: "public"
      }
    )

    perform_enqueued_jobs do
      click_on("Export")
    end

    within(".alert") do
      expect(page).to have_text("Your export is being processed")
      click_on("Exports")
    end

    click_on("phone_numbers_")

    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page).to have_text("+12513095500")
    expect(page).to have_text("public")
    expect(page).to have_text("local")
    expect(page).to have_text("US")
    expect(page).to have_text("1.15")
    expect(page).to have_text("USD")
    expect(page).to have_text("AR")
    expect(page).to have_text("Little Rock")
    expect(page).to have_text("528")
    expect(page).to have_text("LITTLEROCK")
    expect(page).to have_text("34.748463")
    expect(page).to have_text("-92.284434")

    expect(page).to have_no_text("+12513095501")
  end

  it "Import phone numbers" do
    carrier = create(:carrier, billing_currency: "USD")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path
    click_on("Import")
    attach_file("File", file_fixture("phone_numbers.csv"))

    perform_enqueued_jobs do
      click_on("Upload")
    end

    within(".alert") do
      expect(page).to have_text("Your import is being processed")
      click_on("Imports")
    end

    expect(page).to have_text("Completed")
    expect(page).to have_text("phone_numbers.csv")
  end

  it "Fail to import phone numbers" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path
    click_on("Import")
    attach_file("File", file_fixture("recording.mp3"))
    click_on("Upload")

    expect(page).to have_text("Failed to create import: File has an invalid content type (authorized content type is CSV)")
  end

  it "Show a phone number" do
    carrier = create(:carrier)
    phone_number = create(
      :phone_number,
      number: "12513095500",
      carrier:,
      metadata: {
        my_custom_field: "my_custom_field_value"
      },
      type: :local,
      visibility: :public,
      iso_country_code: "US",
      iso_region_code: "AR",
      locality: "Little Rock",
      lata: "528",
      rate_center: "LITTLEROCK"
    )
    account = create(:account, carrier:, name: "Rocket Rides")
    active_plan = create(:phone_number_plan, phone_number:, account:, amount: Money.from_amount(1.15, "USD"))
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    expect(page).to have_text("+1 (251) 309-5500")
    expect(page).to have_text("my_custom_field")
    expect(page).to have_text("my_custom_field_value")
    expect(page).to have_text("Local")
    expect(page).to have_text("Public")
    expect(page).to have_text("United States of America")
    expect(page).to have_text("Arkansas")
    expect(page).to have_text("Little Rock")
    expect(page).to have_text("528")
    expect(page).to have_text("LITTLEROCK")

    within("#billing") do
      expect(page).to have_link("Rocket Rides", href: dashboard_account_path(account))
      expect(page).to have_link("$1.15", href: dashboard_phone_number_plan_path(active_plan))
    end
  end

  it "Create a phone number" do
    carrier = create(:carrier, country_code: "KH")
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path

    click_on("New")
    fill_in("Number", with: "1294")
    select("Short code", from: "Type")
    choose("Public")
    click_on("Create Phone number")

    expect(page).to have_text("Phone number was successfully created")

    within("#general") do
      expect(page).to have_text("1294")
    end

    within("#properties") do
      expect(page).to have_text("Cambodia")
      expect(page).to have_text("Short code")
      expect(page).to have_text("Public")
    end
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_phone_number_path
    click_on("Create Phone number")

    expect(page).to have_text("can't be blank")
  end

  it "Update a phone number" do
    carrier = create(:carrier, billing_currency: "CAD")
    create(:account, :carrier_managed, carrier:, name: "My Carrier Account")
    user = create(:user, :carrier, carrier:)
    phone_number = create(
      :phone_number,
      carrier:,
      number: "12505550199",
      iso_country_code: "US",
      visibility: :public
    )

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_on("Edit")

    select("Canada", from: "Country")
    fill_in("Region", with: "ON")
    fill_in("Locality", with: "Toronto")
    select("Mobile", from: "Type")
    fill_in("Price", with: "1.15")
    choose("Private")
    fill_in("LATA", with: "888")
    fill_in("Rate center", with: "NEWTORONTO")
    fill_in("Latitude", with: "43.6008")
    fill_in("Longitude", with: "-79.5053")
    enhanced_select("My Carrier Account", from: "Account")

    click_on("Update Phone number")

    expect(page).to have_text("Phone number was successfully updated")

    within("#properties") do
      expect(page).to have_text("Canada")
      expect(page).to have_text("Ontario")
      expect(page).to have_text("Toronto")
      expect(page).to have_text("Mobile")
      expect(page).to have_text("$1.15")
      expect(page).to have_text("Private")
      expect(page).to have_text("888")
      expect(page).to have_text("NEWTORONTO")
      expect(page).to have_text("43.6008")
      expect(page).to have_text("-79.5053")
    end

    within("#billing") do
      expect(page).to have_text("My Carrier Account")
    end
  end

  it "Delete a phone number" do
    carrier = create(:carrier)
    phone_number = create(:phone_number, carrier:, number: "1234")
    account = create(:account, carrier:)
    incoming_phone_number = create(:incoming_phone_number, :released, number: "1234", phone_number:, account:)
    create(:phone_call, :inbound, carrier:, phone_number:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_on("Delete")

    expect(page).to have_text("Phone number was successfully destroyed")
    expect(page).to have_no_text("1234")

    visit(dashboard_incoming_phone_number_path(incoming_phone_number))
    expect(page).to have_text("1234")
  end
end
