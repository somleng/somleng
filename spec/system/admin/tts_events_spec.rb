require "rails_helper"

RSpec.describe "Admin/TTS Events" do
  it "List TTS events" do
    create(:tts_event, num_chars: 500)

    page.driver.browser.authorize("admin", "password")
    visit admin_tts_events_path

    expect(page).to have_content("500")
  end
end
