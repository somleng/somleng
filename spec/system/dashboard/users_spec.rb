require "rails_helper"

RSpec.describe "Users" do
  it "List and filter users" do
    carrier = create(:carrier)
    user = create(:user, carrier: carrier)
    create(:user, name: "John Doe", carrier: carrier, created_at: Time.utc(2021, 12, 1))
    create(:user, name: "Joe Bloggs", carrier: carrier, created_at: Time.utc(2021, 10, 10))

    sign_in(user)
    visit dashboard_users_path(filter: { from_date: "01/12/2021", to_date: "15/12/2021" })

    expect(page).to have_content("John Doe")
    expect(page).not_to have_content("Joe Bloggs")
  end
end
