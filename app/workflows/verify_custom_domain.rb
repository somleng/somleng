require "resolv"

class VerifyCustomDomain < ApplicationWorkflow
  attr_reader :custom_domain, :dns_resolver

  def initialize(custom_domain, dns_resolver: DNSResolver.new)
    @custom_domain = custom_domain
    @dns_resolver = dns_resolver
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
    dns_resolver.resolve?(host: custom_domain.host, record_value: custom_domain.txt_record)
  end
end
