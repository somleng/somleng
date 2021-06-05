require "rails_helper"

RSpec.describe "Carrier Settings" do
  it "Update carrier settings" do
    carrier = create(:carrier, name: "My Carrier")
    user = create(:user, :carrier, :owner, carrier: carrier)

    sign_in(user)
    visit dashboard_root_path

    click_link("Edit")
    fill_in("Name", with: "T-Mobile")
    select("Zambia", from: "Country")
    attach_file("Logo", file_fixture("carrier_logo.jpeg"))
    click_button("Update Carrier Settings")

    expect(page).to have_content("Carrier Settings were successfully updated")
    expect(page).to have_content("T-Mobile")
    expect(page).to have_content("Zambia")
  end
end
