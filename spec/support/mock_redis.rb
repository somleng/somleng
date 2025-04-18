AppSettings.redis_client = -> { MockRedis.new }

RSpec.configure do |config|
  config.before do
    AppSettings.redis.with { |redis| redis.flushall }
  end
end
