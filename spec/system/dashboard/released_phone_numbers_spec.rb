require "rails_helper"

RSpec.describe "Released Phone Numbers" do
  it "List and filter released phone numbers" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    create(
      :incoming_phone_number,
      :released,
      account:,
      number: "12513095500",
      amount: Money.from_amount(5.00, "CAD"),
      released_at: Time.utc(2024, 4, 26)
    )
    create(:incoming_phone_number, :released, account:, number: "12513095501")
    create(:incoming_phone_number, :active, account:)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)

    visit dashboard_released_phone_numbers_path(
      filter: {
        number: "+1 (251) 309-5500",
        from_date: "26/04/2024",
        to_date: "26/04/2024"
      }
    )

    expect(page).to have_content("+1 (251) 309-5500")
    expect(page).to have_link("Repurchase", href: dashboard_available_phone_numbers_path(filter: { number: "+12513095500" }))
    expect(page).to have_content("$5.00")
  end

  it "List and filter released phone numbers as an account admin" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    create(
      :incoming_phone_number,
      :released,
      account:,
      number: "12513095500",
      amount: Money.from_amount(5.00, "CAD"),
    )
    create(:incoming_phone_number, :released, number: "12513095501")
    user = create(:user, :with_account_membership, account:, carrier:)

    carrier_sign_in(user)

    visit dashboard_released_phone_numbers_path

    expect(page).to have_content("+1 (251) 309-5500")
    expect(page).to have_link("Repurchase", href: dashboard_available_phone_numbers_path(filter: { number: "+12513095500" }))
    expect(page).to have_content("$5.00")
    expect(page).not_to have_content("+1 (251) 309-5501")
  end
end
