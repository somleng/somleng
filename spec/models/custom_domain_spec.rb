require "rails_helper"

RSpec.describe CustomDomain do
  it "revokes email identity on destroy" do
    custom_domain = create(:custom_domain, :mail, host: "example.com")

    expect {
      custom_domain.destroy!
    }.to have_enqueued_job(ExecuteWorkflowJob).with(
      "DeleteEmailIdentity", "example.com"
    )
  end
end
