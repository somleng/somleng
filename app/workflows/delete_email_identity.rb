class DeleteEmailIdentity < ApplicationWorkflow
  attr_reader :email_identity, :client

  def initialize(email_identity, client: nil)
    @email_identity = email_identity
    @client = client || Aws::SESV2::Client.new(
      region: Rails.configuration.app_settings.fetch(:aws_ses_region)
    )
  end

  def call
    client.delete_email_identity(email_identity:)
  end
end
