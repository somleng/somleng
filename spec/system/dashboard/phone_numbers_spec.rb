require "rails_helper"

RSpec.describe "Phone Numbers" do
  it "List and filter phone numbers" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier: carrier)
    create(:phone_number, carrier: carrier, number: "855972222222", created_at: Time.utc(2021, 12, 1))
    create(:phone_number, carrier: carrier, number: "855973333333", created_at: Time.utc(2021, 10, 10))

    sign_in(user)
    visit dashboard_outbound_sip_trunks_path(
      filter: { from_date: "01/12/2021", to_date: "15/12/2021" }
    )

    expect(page).to have_content("855972222222")
    expect(page).not_to have_content("855973333333")
  end
end
