AppSettings.redis_client = -> { MockRedis.new }

RSpec.configure do |config|
  config.before do
    foobar = lambda do |original_method, *args, &block|
      case args.first
      when SimpleCounter::DECREMENT_SCRIPT
        original_method.receiver.decr(args.last.fetch(:keys).first)
      when UniqueFIFOQueue::ENQUEUE_SCRIPT
        key, set_key = args.last.fetch(:keys)
        item = args.last.fetch(:argv).first
        redis = original_method.receiver
        redis.lpush(key, item) if redis.sadd(set_key, item).nonzero?
      else
        original_method.call(*args, &block)
      end
    end

    allow_any_instance_of(MockRedis::TransactionWrapper).to receive(:eval).and_wrap_original(&foobar)
    allow_any_instance_of(MockRedis::PipelinedWrapper).to receive(:eval).and_wrap_original(&foobar)

    AppSettings.redis.with { |redis| redis.flushall }
  end
end
