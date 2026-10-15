require "rails_helper"

RSpec.describe "TTS Events" do
  it "List and filter TTS Events" do
    tts_event = create(:tts_event)
    other_tts_event = create(:tts_event, carrier: tts_event.carrier)
    user = create(:user, :carrier, carrier: tts_event.carrier)

    carrier_sign_in(user)
    visit dashboard_tts_events_path(
      filter: {
        account_id: tts_event.account_id,
        from_date: tts_event.created_at,
        to_date: tts_event.created_at
      }
    )

    expect(page).to have_text(tts_event.id)
    expect(page).to have_no_text(other_tts_event.id)

    perform_enqueued_jobs do
      click_on("Export")
    end

    within(".alert") do
      expect(page).to have_text("Your export is being processed")
      click_on("Exports")
    end

    click_on("tts_events_")

    expect(page).to have_text(tts_event.id)
    expect(page).to have_text(tts_event.account_id)
    expect(page).to have_text(tts_event.phone_call_id)
    expect(page).to have_text(tts_event.tts_voice)
    expect(page).to have_text(tts_event.num_chars)
    expect(page).to have_no_text(other_tts_event.id)
  end

  it "Show a TTS Event" do
    tts_event = create(:tts_event)
    user = create(:user, :carrier, carrier: tts_event.carrier)

    carrier_sign_in(user)
    visit dashboard_tts_event_path(tts_event)

    expect(page).to have_text(tts_event.id)
    expect(page).to have_link(
      tts_event.account.name, href: dashboard_account_path(tts_event.account)
    )
    expect(page).to have_link(
      tts_event.phone_call.id,
      href: dashboard_phone_call_path(tts_event.phone_call)
    )
  end
end
