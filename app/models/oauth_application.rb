class OAuthApplication < Doorkeeper::Application
  has_one :oauth_application_settings

  def allow_client_ip?(client_ip)
    return true if oauth_application_settings.whitelisted_ips.empty?

    OAuthApplicationSettings.where(oauth_application: self)
                            .where("? <<= ANY (whitelisted_ips)", client_ip).any?
  end
end
