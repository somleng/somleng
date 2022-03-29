require "rails_helper"

RSpec.describe "Admin/Phone Calls" do
  it "Inspect phone calls" do
    phone_call = create(
      :phone_call,
      status_callback_url: "https://example.com/call-status-callback",
      to: "855718224112"
    )
    recording = create(
      :recording,
      :completed,
      phone_call:,
      status_callback_url: "https://example.com/recording-status-callback"
    )

    page.driver.browser.authorize("admin", "password")
    visit admin_phone_calls_path
    click_link("855718224112")

    expect(page).to have_content("https://example.com/call-status-callback")
    expect(page).to have_content("Recordings")

    click_link(recording.id)
    expect(page).to have_content("https://example.com/recording-status-callback")
  end
end
