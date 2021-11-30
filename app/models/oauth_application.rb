class OAuthApplication < Doorkeeper::Application
  has_one :webhook_endpoint
  has_one :oauth_application_settings
end
