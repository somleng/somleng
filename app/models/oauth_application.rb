class OAuthApplication < Doorkeeper::Application
  has_one :webhook_endpoint
end
