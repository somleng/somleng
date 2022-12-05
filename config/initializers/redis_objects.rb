require "connection_pool"
Redis::Objects.redis = ConnectionPool.new(size: ENV.fetch("DB_POOL", 5), timeout: 5) {
  Redis.new(url: Rails.configuration.app_settings.fetch(:redis_url))
}
