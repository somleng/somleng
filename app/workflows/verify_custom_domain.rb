require "resolv"

class VerifyCustomDomain < ApplicationWorkflow
  attr_reader :custom_domain, :domain_verifier

  def initialize(custom_domain, domain_verifier:)
    @custom_domain = custom_domain
    @domain_verifier = domain_verifier
  end

  def call
    return true if custom_domain.verified?
    return false if verified_domain_exists?

    custom_domain.mark_as_verified! if resolve_dns_record?
  end

  private

  def verified_domain_exists?
    CustomDomain.verified.exists?(host: custom_domain.host)
  end

  def resolve_dns_record?
    domain_verifier.verify
  end
end
