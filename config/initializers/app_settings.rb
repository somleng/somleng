class AppSettings
  class << self
    def app_uri
      Addressable::URI.parse(config_for(:app_url_host))
    end

    def config_for(key)
      Rails.configuration.app_settings.fetch(key)
    end
  end
end
