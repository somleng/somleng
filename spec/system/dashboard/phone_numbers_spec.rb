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
      visibility: :public
    }

    create(:phone_number, common_attributes.merge(number: "12513095500"))
    create(:phone_number, common_attributes.merge(number: "12513095501", created_at: Time.utc(2021, 10, 10)))
    create(:phone_number, common_attributes.merge(number: "12513095502", type: :mobile))
    create(:phone_number, common_attributes.merge(number: "12513095503", visibility: :private))
    create(:phone_number, common_attributes.merge(number: "12513095504", iso_country_code: "CA"))
    create(:phone_number, common_attributes.merge(number: "12013095505"))

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path(
      filter: {
        country: "US",
        type: "local",
        from_date: "27/04/2024",
        to_date: "27/04/2024",
        assigned: false,
        visibility: "public",
        area_code: "251"
      }
    )

    expect(page).to have_content("+1 (251) 309-5500")
    expect(page).not_to have_content("+1 (251) 309-5501")
    expect(page).not_to have_content("+1 (251) 309-5502")
    expect(page).not_to have_content("+1 (251) 309-5503")
    expect(page).not_to have_content("+1 (251) 309-5504")
    expect(page).not_to have_content("+1 (201) 309-5505")

    click_on("Delete")

    expect(page).to have_content("Phone numbers were successfully destroyed")
    expect(page).not_to have_content("+1 (251) 309-5500")
    expect(page).not_to have_selector(:link_or_button, "Delete")
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
      type: :local
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
      expect(page).to have_content("Your export is being processed")
      click_on("Exports")
    end

    click_on("phone_numbers_")

    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page).to have_content("+12513095500")
    expect(page).to have_content("public")
    expect(page).to have_content("local")
    expect(page).to have_content("US")
    expect(page).to have_content("1.15")
    expect(page).to have_content("USD")

    expect(page).not_to have_content("+12513095501")
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
      expect(page).to have_content("Your import is being processed")
      click_on("Imports")
    end

    expect(page).to have_content("Completed")
    expect(page).to have_content("phone_numbers.csv")
  end

  it "Show a phone number" do
    carrier = create(:carrier)
    phone_number = create(:phone_number, number: "12513095500", carrier:)
    account = create(:account, carrier:, name: "Rocket Rides")
    active_plan = create(:phone_number_plan, phone_number:, account:, amount: Money.from_amount(1.15, "USD"))
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    expect(page).to have_content("+1 (251) 309-5500")
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
    choices_select("Short code", from: "Type")
    choose("Public")
    click_on("Create Phone number")

    expect(page).to have_content("Phone number was successfully created")

    within("#general") do
      expect(page).to have_content("1294")
    end

    within("#properties") do
      expect(page).to have_content("Cambodia")
      expect(page).to have_content("Short code")
      expect(page).to have_content("Public")
    end
  end

  it "Handles validations" do
    user = create(:user, :carrier, :admin)

    carrier_sign_in(user)
    visit new_dashboard_phone_number_path
    click_on("Create Phone number")

    expect(page).to have_content("can't be blank")
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
    choices_select("Canada", from: "Country")
    choices_select("Mobile", from: "Type")
    fill_in("Price", with: "1.15")
    choose("Private")
    choices_select("My Carrier Account", from: "Account")

    click_on("Update Phone number")

    expect(page).to have_content("Phone number was successfully updated")

    within("#properties") do
      expect(page).to have_content("Canada")
      expect(page).to have_content("Mobile")
      expect(page).to have_content("$1.15")
      expect(page).to have_content("Private")
    end

    within("#billing") do
      expect(page).to have_content("My Carrier Account")
    end
  end

  it "Delete a phone number" do
    carrier = create(:carrier)
    phone_number = create(:phone_number, carrier:, number: "1234")
    create(:phone_call, :inbound, carrier:, phone_number:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_number_path(phone_number)

    click_on("Delete")

    expect(page).to have_content("Phone number was successfully destroyed")
    expect(page).not_to have_content("1234")
  end
end
