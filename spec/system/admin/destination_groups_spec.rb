require "rails_helper"

RSpec.describe "Admin/Destination Groups" do
 it "List destination groups" do
    destination_group = create(:destination_group)

    page.driver.browser.authorize("admin", "password")
    visit admin_destination_groups_path
    click_on(destination_group.id)

    expect(page).to have_content(destination_group.id)
  end
end
