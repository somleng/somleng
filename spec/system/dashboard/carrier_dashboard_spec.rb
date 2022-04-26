require "rails_helper"

RSpec.describe "Carrier Dashboard" do
  it "displays account trial info" do
    carrier = create(:carrier, :with_oauth_application, :restricted)
    user = create(:user, :carrier, carrier:)

    sign_in(user)
    visit dashboard_root_path

    expect(page).to have_content("Account (Trial)")
  end
end
