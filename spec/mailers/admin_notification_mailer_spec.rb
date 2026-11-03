require "rails_helper"

RSpec.describe AdminNotificationMailer, type: :mailer do
  describe "#alphanumeric_sender_ids_pending_approval" do
    it "sends notification emails" do
      carrier = create(
        :carrier,
        name: "Rocket Communications",
        custom_app_host: "dashboard.rocket-communications.com",
        website: "https://rocket-communications.com"
      )
      user = create(:user, :carrier, carrier:)

      mail = AdminNotificationMailer.alphanumeric_sender_ids_pending_approval(recipients: carrier.carrier_users.pluck(:email), carrier:)

      expect(mail).to have_attributes(
        to: contain_exactly(user.email),
        subject: "New Alphanumeric Sender IDs pending approval"
      )

      mail_body = Capybara.string(mail.html_part.body.raw_source)

      expect(mail_body).to have_text("There are Alphanumeric Sender IDs waiting for your review.")
      expect(mail_body).to have_link("Review on Dashboard", href: dashboard_alphanumeric_sender_ids_url(filter: { status: :pending_approval }, host: "dashboard.rocket-communications.com"))
      expect(mail_body).to have_link("notification preferences", href: edit_dashboard_notification_preferences_url(host: "dashboard.rocket-communications.com"))
      expect(mail_body).to have_link("https://rocket-communications.com")
    end
  end

  describe "#alphanumeric_sender_id_request_updated" do
    it "sends notification emails" do
      carrier = create(
        :carrier,
        name: "Rocket Communications",
        custom_app_host: "dashboard.rocket-communications.com",
        website: "https://rocket-communications.com"
      )
      account = create(:account, :customer_managed, carrier:)
      alphanumeric_sender_id = create(:alphanumeric_sender_id, :approved, account:, sender_id: "MyCompany")

      mail = AdminNotificationMailer.alphanumeric_sender_id_request_updated(
        recipients: carrier.account_users.pluck(:email),
        alphanumeric_sender_id:
      )

      expect(mail).to have_attributes(
        to: contain_exactly(account.owner.email),
        subject: "Rocket Communications - Your Alphanumeric Sender ID request has been approved."
      )

      mail_body = Capybara.string(mail.html_part.body.raw_source)

      expect(mail_body).to have_text("Your Alphanumeric Sender ID request for MyCompany has been approved.")
      expect(mail_body).to have_link("View on Dashboard", href: dashboard_alphanumeric_sender_ids_url(filter: { id: alphanumeric_sender_id.id }, host: "dashboard.rocket-communications.com"))
      expect(mail_body).to have_link("notification preferences", href: edit_dashboard_notification_preferences_url(host: "dashboard.rocket-communications.com"))
      expect(mail_body).to have_link("https://rocket-communications.com")
    end
  end
end
