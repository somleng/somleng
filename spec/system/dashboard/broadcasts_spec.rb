require "rails_helper"

RSpec.describe "Broadcasts" do
  it "List broadcasts" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:, id: "d28bb460-1324-4aa5-860a-8ef48fb5ca7f")

    carrier_sign_in(user)
    visit dashboard_root_path

    click_on "Broadcasts"

    expect(page).to have_content("Flood warning for Punjab.")

    click_on "b827279c-486a-40a2-845a-30d38ada6ca5"
    click_on "Start"

    expect(page).to have_content("Broadcast was successfully updated.")
  end
end
