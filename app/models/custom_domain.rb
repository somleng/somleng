class CustomDomain < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  belongs_to :carrier

  enumerize :type, in: %i[dashboard api mail]
  enumerize :dns_record_type, in: %i[txt cname]
  has_secure_token :verification_token

  after_commit :delete_email_identity, on: :destroy

  def self.verified
    where.not(verified_at: nil)
  end

  def self.unverified
    where(verified_at: nil)
  end

  def verified?
    verified_at.present?
  end

  def mark_as_verified!
    touch(:verified_at)
  end

  def verify!
    if dns_record_type.txt?
      VerifyCustomDomain.call(self, domain_verifier: DNSRecordVerifier.new(host:, record_value:))
    elsif dkim? && dkim_provider == "amazonses"
      VerifyCustomDomain.call(self, domain_verifier: SESIdentityVerifier.new(host:))
    end
  end

  def record_name
    if dns_record_type.cname? && dkim?
      dkim_tokens.map { |token| "#{token}._domainkey.#{host}" }
    else
      host
    end
  end

  def record_value
    if dns_record_type.txt?
      "somleng-domain-verification=#{verification_token}"
    elsif dkim? && dkim_provider == "amazonses"
      dkim_tokens.map { |token|  "#{token}.dkim.amazonses.com" }
    end
  end

  private

  def dkim?
    verification_data["type"] == "dkim"
  end

  def dkim_tokens
    verification_data["dkim_tokens"]
  end

  def dkim_provider
    verification_data["dkim_provider"]
  end

  def delete_email_identity
    return unless type.mail?

    ExecuteWorkflowJob.perform_later(DeleteEmailIdentity.to_s, host)
  end
end
