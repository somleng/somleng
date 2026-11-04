require "rails_helper"

RSpec.describe "Admin/Alphanumeric Sender IDs" do
  it "List alphanumeric sender ids" do
    alphanumeric_sender_id = create(
      :alphanumeric_sender_id,
      :approved,
      sender_id: "MyBrand",
    )

    page.driver.browser.authorize("admin", "password")
    visit admin_alphanumeric_sender_ids_path

    click_on("MyBrand")

    expect(page).to have_text(alphanumeric_sender_id.id)
    expect(page).to have_text("Approved")
  end
end
