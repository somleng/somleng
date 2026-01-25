class AppSettings
  class << self
    attr_writer :redis_client

    def app_uri
      Addressable::URI.parse(fetch(:app_url_host))
    end

    def fetch(key)
      value = config.fetch(key)
      raise "Missing configuration for: #{key}" if value.blank?
      value
    end

    def stub_rating_engine?
      Rails.env.development? && config.fetch(:stub_rating_engine, true)
    end

    def dig(...)
      config.dig(...)
    end

    def [](...)
      config.[](...)
    end

    def redis
      @redis ||= ConnectionPool.new(size: fetch(:redis_pool_size)) { redis_client.call }
    end

    def redis_client
      @redis_client ||= -> { Redis.new(url: fetch(:redis_url)) }
    end

    private

    def config
      Rails.configuration.app_settings
    end
  end
end
