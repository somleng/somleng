require "rails_helper"

RSpec.describe ErrorLogMailer, type: :mailer do
  describe "#notify" do
    it "handles alerts" do
      carrier = create(
        :carrier,
        name: "Rocket Communications",
        custom_app_host: "dashboard.rocket-communications.com",
        website: "https://rocket-communications.com"
      )
      error_log = create(:error_log, type: :inbound_message, carrier:, error_message: "An error occurred")
      error_log_notification = create(:error_log_notification, error_log:, carrier:)

      mail = ErrorLogMailer.notify(error_log:)

      expect(mail).to have_attributes(
        to: match_array(error_log_notification.email),
        subject: "Rocket Communications - New Issue: An error occurred"
      )

      mail_body = Capybara.string(mail.html_part.body.raw_source)

      expect(mail_body).to have_text("Your have received a new issue from Rocket Communications")
      expect(mail_body).to have_text("Inbound message")
      expect(mail_body).to have_text("An error occurred")
      expect(mail_body).to have_link("View on Dashboard", href: dashboard_error_logs_url(host: "dashboard.rocket-communications.com"))
      expect(mail_body).to have_link("notification preferences", href: edit_dashboard_notification_preferences_url(host: "dashboard.rocket-communications.com"))
      expect(mail_body).to have_link("https://rocket-communications.com")
    end

    it "handles alerts to multiple users" do
      carrier = create(:carrier)
      error_log = create(:error_log, carrier:)
      error_log_notifications = create_list(:error_log_notification, 2, error_log:, carrier:)

      mail = ErrorLogMailer.notify(error_log:)

      expect(mail.to).to match_array(error_log_notifications.pluck(:email))

      mail_body = Capybara.string(mail.html_part.body.raw_source)

      expect(mail_body).to have_text("Other members of your team were also notified about this issue.")
    end
  end
end
