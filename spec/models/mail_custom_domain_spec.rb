require "rails_helper"

RSpec.describe MailCustomDomain do
  it "revokes email identity on destroy" do
    carrier = create(:carrier)
    create(:custom_domain, :mail, carrier:, host: "example.com")

    expect {
      carrier.custom_domain(:mail).destroy!
    }.to have_enqueued_job(ExecuteWorkflowJob).with(
      "DeleteEmailIdentity", "example.com"
    )
  end
end
