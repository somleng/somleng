require "rails_helper"

RSpec.describe VerifyCustomDomainJob do
  it "reschedules a verification" do
    travel_to(Time.zone.local(2022, 12, 1, 12, 0, 0)) do
      custom_domain = create(:custom_domain, host: "example.com")

      VerifyCustomDomainJob.perform_now(custom_domain)

      expect(
        ScheduledJob
      ).to have_been_enqueued.with(
        VerifyCustomDomainJob.to_s,
        custom_domain,
        wait_until: Time.zone.local(2022, 12, 1, 12, 15).to_f
      )
    end
  end

  it "does not reschedule verifications forever" do
    custom_domain = create(
      :custom_domain,
      host: "example.com",
      verification_started_at: 11.days.ago
    )

    VerifyCustomDomainJob.perform_now(custom_domain)

    expect(ScheduledJob).not_to have_been_enqueued
  end

  it "handles deleted domains" do
    custom_domain = create(:custom_domain)

    VerifyCustomDomainJob.perform_later(custom_domain)
    custom_domain.delete
    expect { perform_enqueued_jobs }.not_to raise_error
  end
end
