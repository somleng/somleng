class MailCustomDomain < SimpleDelegator
  # https://docs.aws.amazon.com/ses/latest/APIReference/API_VerifyDomainIdentity.html
  MAX_SES_VERIFICATION_PERIOD = 72.hours

  def expired?
    verification_started_at < MAX_SES_VERIFICATION_PERIOD.ago
  end

  def verifiable?
    record.verifiable? && !expired?
  end

  def record_name
    dkim_tokens.map { |token| "#{token}._domainkey.#{host}" }
  end

  def record_value
    dkim_tokens.map { |token| "#{token}.dkim.amazonses.com" }
  end

  def verify!
    VerifyCustomDomain.call(record, domain_verifier: SESEmailIdentityVerifier.new(host:))
  end

  private

  def dkim_tokens
    verification_data["dkim_tokens"]
  end

  def record
    __getobj__
  end
end
