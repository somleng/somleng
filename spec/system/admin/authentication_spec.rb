require "rails_helper"

RSpec.describe "Admin / Authentication" do
  it "requires basic auth" do
    visit admin_carriers_path

    expect(page).to have_content("HTTP Basic: Access denied")
  end
end
