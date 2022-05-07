require "resolv"

class VerifyCustomDomain < ApplicationWorkflow
  MAX_VERIFICATION_PERIOD = 10.days

  attr_reader :custom_domain, :reverify, :verification_token

  def initialize(custom_domain, reverify: true, verification_token: nil)
    @custom_domain = custom_domain
    @reverify = reverify
    @verification_token = verification_token || custom_domain.verification_token
  end

  def call
    return if custom_domain.verified?
    return if CustomDomain.verified.exists?(host: custom_domain.host)

    if resolve_dns_record?
      custom_domain.verify!
    elsif reverify && custom_domain.verification_started_at > MAX_VERIFICATION_PERIOD.ago
      reschedule_verification
    end
  end

  private

  def resolve_dns_record?
    Resolv::DNS.open do |dns|
      records = dns.getresources(custom_domain.host, Resolv::DNS::Resource::IN::TXT)
      records.find { |record| record.data == verification_token }
    end
  end

  def reschedule_verification
    ScheduledJob.perform_later(
      VerifyCustomDomainJob.to_s,
      custom_domain,
      wait_until: 15.minutes.from_now.to_f
    )
  end
end
