class CreateEmailIdentity < ApplicationWorkflow
  attr_reader :custom_domain, :client

  def initialize(custom_domain, client: nil)
    @custom_domain = custom_domain
    @client = client || Aws::SESV2::Client.new(
      region: Rails.configuration.app_settings.fetch(:aws_ses_region)
    )
  end

  def call
    response = client.create_email_identity(email_identity: custom_domain.host)
    custom_domain.update!(verification_data: { dkim_tokens: response.dkim_attributes.tokens })
  end
end
