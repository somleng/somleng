require "rails_helper"

RSpec.describe DeviseMailer, type: :mailer do
  describe "#confirmation_instructions" do
    it "handles normal domains" do
      carrier = create(:carrier, subdomain: "example")
      user = create(:user, carrier:)

      mail = DeviseMailer.confirmation_instructions(user, "abc")

      mail_body = Capybara.string(mail.html_part.body.raw_source)
      expect(mail_body).to have_link("Confirm my account", href: "http://example.app.lvh.me/users/confirmation?confirmation_token=abc")
    end

    it "handles custom domains" do
      carrier = create(:carrier, custom_app_host: "dashboard.example.com")
      user = create(:user, carrier:)

      mail = DeviseMailer.confirmation_instructions(user, "abc")

      mail_body = Capybara.string(mail.html_part.body.raw_source)
      expect(mail_body).to have_link("Confirm my account", href: "http://dashboard.example.com/users/confirmation?confirmation_token=abc")
    end
  end
end
