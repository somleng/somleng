require "rails_helper"

RSpec.describe "Imports" do
  it "Import phone numbers" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)

    carrier_sign_in(user)
    visit dashboard_phone_numbers_path
    click_on("Import")
    attach_file("File", file_fixture("phone_numbers.csv"))

    perform_enqueued_jobs do
      click_on("Upload")
    end

    within(".alert") do
      expect(page).to have_content("Your import is being processed")
      click_on("Imports")
    end

    expect(page).to have_content("Completed")
    expect(page).to have_content("phone_numbers.csv")
  end
end
