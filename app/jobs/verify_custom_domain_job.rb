class VerifyCustomDomainJob < ApplicationJob
  MAX_VERIFICATION_PERIOD = 7.days

  rescue_from(ActiveJob::DeserializationError) do |e|
    Rails.logger.warn(e.message)
  end

  def perform(custom_domain)
    wrapped_custom_domain = CustomDomain.wrap(custom_domain)
    return unless wrapped_custom_domain.verifiable?
    return if verification_period_expired?(wrapped_custom_domain)

    reschedule_verification(custom_domain) unless wrapped_custom_domain.verify!
  end

  private

  def verification_period_expired?(custom_domain)
    custom_domain.verification_started_at < MAX_VERIFICATION_PERIOD.ago
  end

  def reschedule_verification(custom_domain)
    ScheduledJob.perform_later(
      VerifyCustomDomainJob.to_s,
      custom_domain,
      wait_until: 15.minutes.from_now.to_f
    )
  end
end
