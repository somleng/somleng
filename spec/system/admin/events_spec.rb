require "rails_helper"

RSpec.describe "Admin / Events" do
  it "List events" do
    event = create(:event)

    page.driver.browser.authorize("admin", "password")
    visit admin_events_path

    expect(page).to have_text(event.type)
  end
end
