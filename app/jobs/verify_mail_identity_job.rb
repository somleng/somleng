class VerifyCustomDomainJob < ApplicationJob
  MAX_VERIFICATION_PERIOD = 72.hours

  rescue_from(ActiveJob::DeserializationError) do |e|
    Rails.logger.warn(e.message)
  end

  def perform(custom_domain)
    return if verification_period_expired?(custom_domain)
    return if VerifyCustomDomain.call(custom_domain, domain_verifier: SESIdentityVerifier.new)

    reschedule_verification(custom_domain)
  end

  private

  def verification_period_expired?(custom_domain)
    custom_domain.verification_started_at < MAX_VERIFICATION_PERIOD.ago
  end

  def reschedule_verification(custom_domain)
    ScheduledJob.perform_later(
      VerifyMailIdentityJob.to_s,
      custom_domain,
      wait_until: 15.minutes.from_now.to_f
    )
  end
end
