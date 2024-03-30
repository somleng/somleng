require "connection_pool"

class AppSettings
  class << self
    attr_writer :redis_client

    def redis
      @redis ||= ConnectionPool.new(size: config_for(:redis_pool_size)) { redis_client.call }
    end

    def redis_client
      @redis_client ||= -> { Redis::Namespace.new(Rails.env, redis: Redis.new(url: config_for(:redis_url))) }
    end

    def app_uri
      Addressable::URI.parse(config_for(:app_url_host))
    end

    def config_for(key)
      Rails.configuration.app_settings.fetch(key)
    end
  end
end
