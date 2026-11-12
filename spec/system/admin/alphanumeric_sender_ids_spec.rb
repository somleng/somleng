require "rails_helper"

RSpec.describe "Admin/Alphanumeric Sender IDs" do
  it "List alphanumeric sender ids" do
    alphanumeric_sender_id = create(
      :alphanumeric_sender_id,
      :approved,
      sender_id: "MyBrand",
    )
    create(
      :messaging_service_alphanumeric_sender_id,
      messaging_service: create(
        :messaging_service,
        account: alphanumeric_sender_id.account,
        name: "My Messaging Service"
      ),
      sender_id: alphanumeric_sender_id
    )

    page.driver.browser.authorize("admin", "password")
    visit admin_alphanumeric_sender_ids_path

    click_on("MyBrand")

    expect(page).to have_text(alphanumeric_sender_id.id)
    expect(page).to have_text("Approved")
    expect(page).to have_link("My Messaging Service")
  end
end
