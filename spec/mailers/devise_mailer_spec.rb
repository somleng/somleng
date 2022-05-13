require "rails_helper"

RSpec.describe DeviseMailer, type: :mailer do
  describe "#confirmation_instructions" do
    it "handles normal domains" do
      user = create(:user)

      mail = DeviseMailer.confirmation_instructions(user, "abc")

      sender = Rails.configuration.app_settings.fetch(:mailer_sender)
      expect(mail).to have_attributes(
        from: [sender],
        reply_to: [sender]
      )
    end

    it "handles custom domains" do
      carrier = create(:carrier)
      create(:custom_domain, :mail, :verified, carrier:, host: "example.com")
      create(:custom_domain, :dashboard, :verified, carrier:, host: "dashboard.example.com")
      user = create(:user, carrier:)

      mail = DeviseMailer.confirmation_instructions(user, "abc")

      expect(mail).to have_attributes(
        from: ["no-reply@example.com"],
        reply_to: ["no-reply@example.com"]
      )
      mail_body = Capybara.string(mail.body.encoded)
      expect(mail_body).to have_link("Confirm my account", href: "http://dashboard.example.com/users/confirmation?confirmation_token=abc")
    end
  end
end
