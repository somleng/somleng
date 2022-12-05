require "connection_pool"

Redis::Objects.redis = ConnectionPool.new(size: ENV.fetch("DB_POOL", 5), timeout: 5) do
  Redis::Namespace.new(
    Rails.env,
    redis: Redis.new(url: Rails.configuration.app_settings.fetch(:redis_url))
  )
end
