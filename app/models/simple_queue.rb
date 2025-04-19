class SimpleQueue
  attr_reader :key, :backend

  def initialize(key:, **options)
    @key = key
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def enqueue(item)
    backend.with do
      _1.lpush(key, item)
    end
  end

  def dequeue(&)
    tmp_queue_key = "tmp:#{key}"
    item = backend.with do
      _1.rpoplpush(key, tmp_queue_key)
    end

    return if item.blank?
    yield(item)

    backend.with do
      _1.lrem(tmp_queue_key, 1, item)
    end
  rescue Exception => e
    backend.with do
      _1.rpoplpush(tmp_queue_key, key)
    end

    raise(e)
  end

  def peek
    backend.with do
      _1.lrange(key, -1, -1).first
    end
  end

  def empty?
    peek.blank?
  end
end
