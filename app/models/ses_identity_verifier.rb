class SESIdentityVerifier
  def verify(host:, client: nil, **_options)
    client ||= Aws::SESV2::Client.new(
      region: Rails.application.app_settings.fetch(:ses_region)
    )

    resp = client.get_email_identity(
      email_identity: "Identity", # required
    )
  end
end
