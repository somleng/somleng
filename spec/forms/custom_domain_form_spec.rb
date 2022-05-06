require "rails_helper"

RSpec.describe CustomDomainForm do
  describe "validations" do
    it "validates the dashboard host" do
      carrier = create(:carrier)
      form = CustomDomainForm.new(
        carrier:,
        dashboard_host: "foo bar.com"
      )

      expect(form).to be_invalid
      expect(form.errors[:dashboard_host]).to be_present
    end

    it "validates the api host" do
      carrier = create(:carrier)
      form = CustomDomainForm.new(
        carrier:,
        api_host: "foo bar.com"
      )

      expect(form).to be_invalid
      expect(form.errors[:api_host]).to be_present
    end
  end

  describe "#save" do
    it "creates a custom domain" do
      carrier = create(:carrier)
      form = CustomDomainForm.new(
        dashboard_host: "dashboard.example.com",
        api_host: "api.example.com"
      )
      form.carrier = carrier

      result = form.save

      expect(result).to eq(true)
      expect(form.carrier).to have_attributes(
        custom_dashboard_domain: have_attributes(
          host: "dashboard.example.com"
        ),
        custom_api_domain: have_attributes(
          host: "api.example.com"
        )
      )
      expect(ExecuteWorkflowJob).to have_been_enqueued.with("VerifyCustomDomain", carrier.custom_dashboard_domain)
      expect(ExecuteWorkflowJob).to have_been_enqueued.with("VerifyCustomDomain", carrier.custom_api_domain)
    end

    it "updates an existing domain" do
      carrier = create(:carrier, :with_custom_domain)
      form = CustomDomainForm.new(
        dashboard_host: "dashboard.example.com",
        api_host: "api.example.com"
      )
      form.carrier = carrier

      result = form.save

      expect(result).to eq(true)
      expect(form.carrier).to have_attributes(
        custom_dashboard_domain: have_attributes(
          host: "dashboard.example.com"
        ),
        custom_api_domain: have_attributes(
          host: "api.example.com"
        )
      )
      expect(ExecuteWorkflowJob).to have_been_enqueued.with("VerifyCustomDomain", carrier.custom_dashboard_domain)
      expect(ExecuteWorkflowJob).to have_been_enqueued.with("VerifyCustomDomain", carrier.custom_api_domain)
    end
  end
end
