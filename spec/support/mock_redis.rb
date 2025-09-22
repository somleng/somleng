AppSettings.redis_client = -> { MockRedis.new }

RSpec.configure do |config|
  config.before do
    stubbed_implementations = lambda do |original_method, *args, &block|
      case args.first
      when SimpleCounter::DECREMENT_SCRIPT
        original_method.receiver.decr(args.last.fetch(:keys).first)
      when UniqueFIFOQueue::ENQUEUE_SCRIPT
        key, tmp_key = args.last.fetch(:keys)
        score, item = args.last.fetch(:argv)
        redis = original_method.receiver
        return 0 if redis.zscore(key, item) || redis.zscore(tmp_key, item)

        redis.zadd(key, score, item)
        1
      when UniqueFIFOQueue::DEQUEUE_SCRIPT
        key, tmp_key, processing_hash = args.last.fetch(:keys)
        proc_started = args.last.fetch(:argv).first
        redis = original_method.receiver
        item, score = redis.zrange(key, 0, 0, with_scores: true).first
        return if item.nil?

        redis.zrem(key, item)
        redis.zadd(tmp_key, score, item, nx: true)
        redis.hset(processing_hash, item, proc_started)
        item
      when UniqueFIFOQueue::RESCUE_SCRIPT
        key, tmp_key, processing_hash = args.last.fetch(:keys)
        item = args.last.fetch(:argv).first
        redis = original_method.receiver
        score = redis.zscore(tmp_key, item)
        return if score.nil?

        redis.zrem(tmp_key, item)
        redis.hdel(processing_hash, item)
        redis.zadd(key, score, item, nx: true)
        1
      when UniqueFIFOQueue::RECOVER_SCRIPT
        tmp_key, key, processing_hash = args.last.fetch(:keys)
        older_than = args.last.fetch(:argv).first
        redis = original_method.receiver
        members = redis.zrange(tmp_key, 0, -1, with_scores: true)
        return 0 if members.empty?

        moved = 0

        members.each do |member, score|
          proc_ts = redis.hget(processing_hash, member)
          if proc_ts.nil? || proc_ts.to_f <= older_than.to_f
            redis.zadd(key, score, member, nx: true)
            redis.zrem(tmp_key, member)
            redis.hdel(processing_hash, member)
            moved += 1
          end
        end

        moved
      else
        original_method.call(*args, &block)
      end
    end

    allow_any_instance_of(MockRedis::TransactionWrapper).to receive(:eval).and_wrap_original(&stubbed_implementations)
    allow_any_instance_of(MockRedis::PipelinedWrapper).to receive(:eval).and_wrap_original(&stubbed_implementations)

    AppSettings.redis.with { |redis| redis.flushall }
  end
end
