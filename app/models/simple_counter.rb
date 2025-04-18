class SimpleCounter
  attr_reader :backend

  def initialize(**options)
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def increment(key)
    backend.with do |connection|
      connection.incr(key)
    end
  end

  def decrement(key)
    backend.with do |connection|
      connection.decr(key)
    end
  end

  def get(key)
    backend.with do |connection|
      connection.get(key)
    end
  end
end
