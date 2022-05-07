require "resolv"

class VerifyCustomDomain < ApplicationWorkflow
  attr_reader :custom_domain, :verification_token

  def initialize(custom_domain, verification_token: nil)
    @custom_domain = custom_domain
    @verification_token = verification_token || custom_domain.verification_token
  end

  def call
    return if custom_domain.verified?
    return reschedule_verification unless resolve_dns_record?

    custom_domain.verify!
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
