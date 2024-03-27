require "rails_helper"

RSpec.describe "Admin/Media Streams" do
  it "Inspect Media Streams" do
    media_stream = create(:media_stream, url: "wss://example.com/audio")
    media_stream_event = create(:media_stream_event, media_stream:, type: "connect")

    page.driver.browser.authorize("admin", "password")
    visit admin_media_streams_path

    expect(page).to have_content(media_stream.id)

    click_on(media_stream.id)

    expect(page).to have_content("wss://example.com/audio")
    expect(page).to have_content(media_stream_event.id)

    click_on(media_stream_event.id)

    expect(page).to have_content("connect")
  end
end
