class UniqueFIFOQueue
  ENQUEUE_SCRIPT = <<~LUA
    if redis.call("SADD", KEYS[2], ARGV[1]) == 1 then
      redis.call("LPUSH", KEYS[1], ARGV[1])
      return 1
    else
      return 0
    end
  LUA

  attr_reader :key, :set_key, :backend

  def initialize(key:, **options)
    @key = key
    @set_key = "set:#{key}"
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def enqueue(item)
    backend.with do |connection|
      connection.eval(ENQUEUE_SCRIPT, keys: [ key, set_key ], argv: [ item ])
    end
  end

  def dequeue(&)
    tmp_queue_key = "tmp:#{key}"
    item = backend.with do
      _1.rpoplpush(key, tmp_queue_key)
    end

    return if item.blank?
    yield(item)

    backend.with do |connection|
      connection.multi do |transaction|
        transaction.lrem(tmp_queue_key, 1, item)
        transaction.srem(set_key, item)
      end
    end
  rescue Exception => e
    backend.with do
      _1.rpoplpush(tmp_queue_key, key)
    end

    raise(e)
  end

  def peek
    backend.with { _1.lrange(key, -1, -1).first }
  end

  def empty?
    size.zero?
  end

  def size
    backend.with { _1.llen(key) }
  end
end
