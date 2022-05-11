require "rails_helper"

RSpec.describe CustomDomainForm do
  describe "validations" do
    it "validates the dashboard host" do
      form = CustomDomainForm.new(
        dashboard_host: "foo bar.com"
      )

      expect(form).to be_invalid
      expect(form.errors[:dashboard_host]).to be_present
    end

    it "validates the api host" do
      form = CustomDomainForm.new(
        api_host: "foo bar.com"
      )

      expect(form).to be_invalid
      expect(form.errors[:api_host]).to be_present
    end

    it "validates the hosts are unique" do
      form = CustomDomainForm.new(
        dashboard_host: "example.com",
        api_host: "example.com"
      )

      expect(form).to be_invalid
      expect(form.errors[:api_host]).to be_present
    end

    it "validates the host is available" do
      create(:custom_domain, :dashboard, :verified, host: "dashboard.example.com")
      create(:custom_domain, :api, host: "api.example.com")

      form = CustomDomainForm.new(
        dashboard_host: "dashboard.example.com",
        api_host: "api.example.com"
      )

      expect(form).to be_invalid
      expect(form.errors[:dashboard_host]).to be_present
      expect(form.errors[:api_host]).not_to be_present
    end
  end

  describe "#save" do
    it "creates a custom domain" do
      carrier = create(:carrier)
      form = CustomDomainForm.new(
        dashboard_host: "dashboard.example.com",
        api_host: "api.example.com",
        mail_host: "example.com"
      )
      form.carrier = carrier

      result = form.save

      expect(result).to eq(true)
      expect(carrier.custom_domain(:dashboard)).to have_attributes(
        host: "dashboard.example.com",
        verification_started_at: be_present,
        verified_at: be_blank
      )
      expect(carrier.custom_domain(:api)).to have_attributes(
        host: "api.example.com",
        verification_started_at: be_present,
        verified_at: be_blank
      )
      expect(carrier.custom_domain(:mail)).to have_attributes(
        host: "example.com",
        verification_started_at: be_present,
        verified_at: be_blank
      )
      expect(VerifyCustomDomainJob).to have_been_enqueued.with(
        carrier.custom_domain(:dashboard)
      )
      expect(VerifyCustomDomainJob).to have_been_enqueued.with(
        carrier.custom_domain(:api)
      )
      expect(ExecuteWorkflowJob).to have_been_enqueued.with(
        "CreateEmailIdentity", carrier.custom_domain(:mail)
      )
      expect(VerifyEmailIdentityJob).to have_been_enqueued.with(
        carrier.custom_domain(:mail)
      )
    end
  end
end
