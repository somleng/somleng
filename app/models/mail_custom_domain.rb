class MailCustomDomain < CustomDomain
  # https://docs.aws.amazon.com/ses/latest/APIReference/API_VerifyDomainIdentity.html
  MAX_SES_VERIFICATION_PERIOD = 72.hours

  after_commit :delete_email_identity, on: :destroy

  def expired?
    verification_started_at < MAX_SES_VERIFICATION_PERIOD.ago
  end

  def verifiable?
    super && !expired?
  end

  def record_name
    dkim_tokens.map { |token| "#{token}._domainkey.#{host}" }
  end

  def record_value
    dkim_tokens.map { |token| "#{token}.dkim.amazonses.com" }
  end

  private

  def dkim_tokens
    verification_data["dkim_tokens"]
  end

  def delete_email_identity
    ExecuteWorkflowJob.perform_later(DeleteEmailIdentity.to_s, host)
  end
end
