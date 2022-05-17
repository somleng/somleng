class SESEmailIdentityVerifier
  attr_reader :host, :client

  def initialize(host:, client: nil)
    @host = host
    @client = client || Aws::SESV2::Client.new(
      region: Rails.configuration.app_settings.fetch(:aws_ses_region)
    )
  end

  def verify
    response = client.get_email_identity(email_identity: host)

    response.verified_for_sending_status
  end
end
