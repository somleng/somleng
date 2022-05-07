require "rails_helper"

RSpec.describe VerifyCustomDomain do
  it "verifies a domain" do
    custom_domain = create(:custom_domain, host: "example.com")

    VerifyCustomDomain.call(custom_domain, verification_token: "wgyf8z8cgvm2qmxpnbnldrcltvk4xqfn")

    expect(custom_domain.verified?).to eq(true)
    expect(ScheduledJob).not_to have_been_enqueued
  end

  it "handles duplicate hosts" do
    existing_custom_domain = create(:custom_domain)
    custom_domain = create(:custom_domain, host: existing_custom_domain.host)
    existing_custom_domain.verify!

    VerifyCustomDomain.call(custom_domain)

    expect(custom_domain.verified?).to eq(false)
    expect(ScheduledJob).not_to have_been_enqueued
  end

  it "reschedules a verification" do
    custom_domain = create(:custom_domain, host: "example.com")

    travel_to(Time.zone.local(2022, 12, 1, 12, 0, 0)) do
      VerifyCustomDomain.call(custom_domain)

      expect(
        ScheduledJob
      ).to have_been_enqueued.with(
        VerifyCustomDomainJob.to_s,
        custom_domain,
        wait_until: Time.zone.local(2022, 12, 1, 12, 15).to_f
      )
    end
  end

  it "handles deleted domains" do
    custom_domain = create(:custom_domain)

    VerifyCustomDomainJob.perform_later(custom_domain)
    custom_domain.delete
    expect { perform_enqueued_jobs }.not_to raise_error
  end
end
