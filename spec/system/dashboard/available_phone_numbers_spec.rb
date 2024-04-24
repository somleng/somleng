require "rails_helper"

RSpec.describe "Available Phone Numbers" do
  it "List and filter available phone numbers" do
    carrier = create(:carrier, country_code: "CA", billing_currency: "CAD")
    account = create(:account, carrier:)
    phone_number = create(:phone_number, number: "12513095500", carrier:, type: :local, price: Money.from_amount(5.00, "CAD"))
    create(:phone_number, number: "12513095501", carrier:, iso_country_code: "US")
    create(:phone_number, number: "12513095502", carrier:, type: :mobile)
    create(:phone_number, number: "12513095503", account:, carrier:, type: :local)
    create(:phone_number, :disabled, number: "12513095504", carrier:, type: :local)
    create(:phone_number, number: "12513095505", carrier:, type: :local, price: Money.from_amount(5.00, "USD"))
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)

    visit dashboard_available_phone_numbers_path(
      filter: {
        country: "CA",
        type: "local",
        currency: "CAD"
      }
    )

    expect(page).to have_content("+1 (251) 309-5500")
    expect(page).to have_link("Buy", href: new_dashboard_phone_number_plan_path(phone_number_id: phone_number))
    expect(page).to have_content("$5.00")
    expect(page).not_to have_content("+1 (251) 309-5501")
    expect(page).not_to have_content("+1 (251) 309-5502")
    expect(page).not_to have_content("+1 (251) 309-5503")
    expect(page).not_to have_content("+1 (251) 309-5504")
    expect(page).not_to have_content("+1 (251) 309-5505")
  end

  it "List and filter available phone numbers as an account admin" do
    carrier = create(:carrier, country_code: "CA", billing_currency: "CAD")
    account = create(:account, carrier:)
    phone_number = create(:phone_number, number: "12513095500", carrier:, price: Money.from_amount(5.00, "CAD"))
    create(:phone_number, number: "12513095501", carrier:, price: Money.from_amount(5.00, "USD"))
    user = create(:user, :with_account_membership, account:, carrier:)

    carrier_sign_in(user)

    visit dashboard_available_phone_numbers_path

    expect(page).to have_content("+1 (251) 309-5500")
    expect(page).to have_link("Buy", href: new_dashboard_phone_number_plan_path(phone_number_id: phone_number))
    expect(page).to have_content("$5.00")
    expect(page).not_to have_content("+1 (251) 309-5501")
  end
end
