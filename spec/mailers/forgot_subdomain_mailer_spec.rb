require "rails_helper"

RSpec.describe ForgotSubdomainMailer, type: :mailer do
  describe "#forgot_subdomain" do
    it "handles multiple domains" do
      carrier = create(:carrier, name: "AT&T")
      other_carrier = create(:carrier, name: "T-Mobile")

      mail = ForgotSubdomainMailer.forgot_subdomain(
        email: "bobchan@example.com", carriers: [carrier, other_carrier]
      )

      mail_body = Capybara.string(mail.body.encoded)
      expect(mail_body).to have_link("AT&T")
      expect(mail_body).to have_link("T-Mobile")
    end
  end
end
