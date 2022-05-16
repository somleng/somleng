class CustomDomain < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  belongs_to :carrier

  enumerize :type, in: %i[dashboard api mail]
  enumerize :dns_record_type, in: %i[txt cname]
  has_secure_token :verification_token

  def self.wrap(custom_domain)
    custom_domain.type.mail? ? MailCustomDomain.new(custom_domain) : custom_domain
  end

  def self.verified
    where.not(verified_at: nil)
  end

  def self.unverified
    where(verified_at: nil)
  end

  def verifiable?
    !verified?
  end

  def verified?
    verified_at.present?
  end

  def mark_as_verified!
    touch(:verified_at)
  end

  def verify!
    VerifyCustomDomain.call(self, domain_verifier: DNSRecordVerifier.new(host:, record_value:))
  end

  def record_name
    host
  end

  def record_value
    "somleng-domain-verification=#{verification_token}"
  end
end
