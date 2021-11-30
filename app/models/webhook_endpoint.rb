class WebhookEndpoint < ApplicationRecord
  belongs_to :oauth_application

  before_create :generate_signing_secret

  private

  def generate_signing_secret
    self.signing_secret ||= SecureRandom.alphanumeric(32)
  end
end
