require "rails_helper"

RSpec.describe "Imports" do
  it "Import phone numbers", :js, :selenium_chrome do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    sign_in(user)
    visit dashboard_phone_numbers_path
    click_button("Import")
    attach_file("File", file_fixture("phone_numbers.csv"))

    perform_enqueued_jobs do
      click_button("Upload")
    end

    within(".alert") do
      expect(page).to have_content("Your import is being processed")
      click_link("Imports")
    end
  end
end
