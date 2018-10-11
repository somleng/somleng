class AppConfig
  def self.read(key)
    credentials = Rails.application.credentials
    env_credentials = credentials[Rails.env.to_sym] || {}
    ENV[key.to_s.upcase] || env_credentials[key] || credentials[key]
  end
end
