class SESIdentityVerifier
  def verify(host:, client: nil, **_options)
    client ||= Aws::SESV2::Client.new(
      region: Rails.configuration.app_settings.fetch(:aws_ses_region)
    )

    response = client.get_email_identity(email_identity: host)

    response.verified_for_sending_status
  end
end
