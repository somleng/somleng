module RedisQueueHelpers
  def build_test_queue(queue)
    decorator = Class.new(SimpleDelegator) do
      def tmp_enqueue(item, score: Time.current, processing_started_at: Time.current)
        object.backend.with do |connection|
          connection.zadd(object.tmp_key, score.to_f, item, nx: true)
          connection.hset(object.processing_hash, item, processing_started_at.to_f)
        end
      end

      def tmp_size
        object.backend.with do |connection|
          connection.zcard(object.tmp_key)
        end
      end

      def tmp_peek
        object.backend.with { |connection| connection.zrange(tmp_key, 0, 0).first }
      end

      private

      def object
        __getobj__
      end
    end

    decorator.new(queue)
  end
end

RSpec.configure do |config|
  config.include RedisQueueHelpers
end
