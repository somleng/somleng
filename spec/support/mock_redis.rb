AppSettings.redis_client = -> { MockRedis.new }

RSpec.configure do |config|
  config.before do
    allow_any_instance_of(MockRedis::TransactionWrapper).to receive(:eval).and_wrap_original do |original_method, *args, &block|
      if args.first == SimpleCounter::DECREMENT_SCRIPT
        original_method.receiver.decr(args.last.fetch(:keys).first)
      else
        original_method.call(*args, &block)
      end
    end
    AppSettings.redis.with { |redis| redis.flushall }
  end
end
