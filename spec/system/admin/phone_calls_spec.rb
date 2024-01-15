require "rails_helper"

RSpec.describe "Admin/Phone Calls" do
  it "Inspect phone calls" do
    sip_trunk = create(:sip_trunk)
    phone_call = create(
      :phone_call,
      sip_trunk:,
      carrier: sip_trunk.carrier,
      status_callback_url: "https://example.com/call-status-callback",
      to: "855718224112"
    )
    recording = create(
      :recording,
      :completed,
      phone_call:,
      status_callback_url: "https://example.com/recording-status-callback"
    )
    internal_phone_call = create(:phone_call, :internal, to: "66814822567")

    page.driver.browser.authorize("admin", "password")
    visit admin_phone_calls_path

    expect(page).to have_no_content(internal_phone_call.to)

    click_on("855718224112")

    expect(page).to have_content("https://example.com/call-status-callback")
    expect(page).to have_content("Recordings")

    click_on(recording.id)
    expect(page).to have_content("https://example.com/recording-status-callback")
  end
end
