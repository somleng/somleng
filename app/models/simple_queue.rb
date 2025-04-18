class SimpleQueue
  attr_reader :backend, :queue_key, :tmp_queue_key

  def initialize(**options)
    @queue_key = options.fetch(:queue_key)
    @tmp_queue_key = options.fetch(:tmp_queue_key)
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def enqueue(item)
    backend.with do
      _1.lpush(queue_key, item)
    end
  end

  def dequeue(&)
    item = backend.with do
      _1.rpoplpush(queue_key, tmp_queue_key)
    end

    return if item.blank?
    yield(item)

    backend.with do
      _1.lrem(tmp_queue_key, 1, item)
    end
  rescue Exception => e
    backend.with do
      _1.rpoplpush(tmp_queue_key, queue_key)
    end

    raise(e)
  end

  def peek
    backend.with do
      _1.lrange(queue_key, -1, -1).first
    end
  end

  def empty?
    peek.blank?
  end
end
