require "rails_helper"

RSpec.describe "Available Phone Numbers" do
  it "List and filter available phone numbers" do
    carrier = create(:carrier, country_code: "CA", billing_currency: "CAD")
    account = create(:account, carrier:, billing_currency: "CAD")
    common_attributes = {
      carrier:,
      type: :local,
      visibility: :public,
      iso_country_code: "CA",
      iso_region_code: "ON",
      locality: "Toronto",
      rate_center: "NEWTORONTO",
      lata: "888"
    }
    phone_number = create(:phone_number, common_attributes.merge(number: "12513095500", price: Money.from_amount(5.00, "CAD")))
    create(:phone_number, common_attributes.merge(number: "12023095500"))
    create(:phone_number, common_attributes.merge(number: "12513095501", iso_country_code: "US", iso_region_code: "AK"))
    create(:phone_number, common_attributes.merge(number: "12513095502", type: :mobile))
    create(:phone_number, :assigned, common_attributes.merge(number: "12513095503"))
    create(:phone_number, common_attributes.merge(number: "12513095504", visibility: :private))
    create(:phone_number, common_attributes.merge(number: "12513095505", price: Money.from_amount(5.00, "USD")))
    create(:phone_number, common_attributes.merge(number: "12513095506", iso_region_code: "BC"))
    create(:phone_number, common_attributes.merge(number: "12513095507", locality: "Vancouver"))
    create(:phone_number, common_attributes.merge(number: "12513095508", rate_center: "AGINCOURT"))

    user = create(:user, :with_account_membership, account:, carrier:)

    carrier_sign_in(user)

    visit dashboard_available_phone_numbers_path(
      filter: {
        country: "CA",
        type: "local",
        area_code: "251",
        region: "ON",
        locality: "Toronto",
        lata: "888",
        rate_center: "NEWTORONTO"
      }
    )

    expect(page).to have_content("+1 (251) 309-5500")
    expect(page).to have_link("Buy", href: new_dashboard_phone_number_plan_path(phone_number_id: phone_number))
    expect(page).to have_content("$5.00")
    expect(page).to have_no_content("+1 (202) 309-5500")
    expect(page).to have_no_content("+1 (251) 309-5501")
    expect(page).to have_no_content("+1 (251) 309-5502")
    expect(page).to have_no_content("+1 (251) 309-5503")
    expect(page).to have_no_content("+1 (251) 309-5504")
    expect(page).to have_no_content("+1 (251) 309-5505")
    expect(page).to have_no_content("+1 (251) 309-5506")
    expect(page).to have_no_content("+1 (251) 309-5507")
    expect(page).to have_no_content("+1 (251) 309-5508")
  end
end
