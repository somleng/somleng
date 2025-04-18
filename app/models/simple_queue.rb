class SimpleQueue
  attr_reader :backend

  def initialize(**options)
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def enqueue(key, item)
    backend.with do |connection|
      connection.lpush(key, item)
    end
  end

  def dequeue(key)
    backend.with do |connection|
      connection.rpop(key)
    end
  end

  def peek(key)
    backend.with do |connection|
      connection.lrange(key, -1, -1).first
    end
  end
end
