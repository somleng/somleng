class AppConfig
  def self.fetch(key)
    config = ENV[key.to_s.upcase] || Rails.application.credentials[key.to_sym]
    raise("Missing configuration '#{key.to_s.upcase}'") if config.blank? && !block_given? && Rails.env.production?
    config = yield if config.blank? && block_given?
    config || key.to_s
  end
end
