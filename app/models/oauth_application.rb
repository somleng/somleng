class OAuthApplication < Doorkeeper::Application
  has_one :webhook_endpoint
  has_many :api_keys, class_name: "CarrierAPIKey", foreign_key: :application_id
  has_many :api_allowed_ip_addresses, class_name: "CarrierAPIAllowedIPAddress", dependent: :delete_all
end
