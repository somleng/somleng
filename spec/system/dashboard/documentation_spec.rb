require "rails_helper"

RSpec.describe "Documentation" do
  it "Shows carrier account API documentation" do
    carrier = create(:carrier, :with_logo, :with_favicon, name: "AT&T", custom_api_host: "api.att.com")
    set_app_host(carrier)

    visit(docs_twilio_api_path)

    expect(page).to have_css("img[alt='AT&T']")
    expect(page).to have_text("AT&T API Documentation")
    expect(page).to have_text("api.att.com")
    expect(page).to have_css('link[rel="icon"]', visible: false)
  end
end
