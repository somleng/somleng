class UniqueFIFOQueue
  ENQUEUE_SCRIPT = <<~LUA
    if redis.call("zscore", KEYS[1], ARGV[2]) then return 0 end
    if redis.call("zscore", KEYS[2], ARGV[2]) then return 0 end
    redis.call("zadd", KEYS[1], ARGV[1], ARGV[2])
    return 1
  LUA

  DEQUEUE_SCRIPT = <<~LUA
    local members = redis.call("zrange", KEYS[1], 0, 0, "WITHSCORES")
    if #members == 0 then return nil end
    local member = members[1]
    local score = members[2]
    local proc_started = ARGV[1]
    redis.call("zrem", KEYS[1], member)
    redis.call("zadd", KEYS[2], "NX", score, member)
    redis.call("hset", KEYS[3], member, proc_started)
    return member
  LUA

  RESCUE_SCRIPT = <<~LUA
    local score = redis.call("zscore", KEYS[2], ARGV[1])
    if not score then return nil end
    redis.call("zrem", KEYS[2], ARGV[1])
    redis.call("hdel", KEYS[3], ARGV[1])
    redis.call("zadd", KEYS[1], "NX", score, ARGV[1])
    return 1
  LUA

  RECOVER_SCRIPT = <<~LUA
    local members = redis.call("zrange", KEYS[1], 0, -1, "WITHSCORES")
    if #members == 0 then return 0 end
    local moved = 0
    for i = 1, #members, 2 do
      local member = members[i]
      local score = members[i+1]
      local proc_ts = redis.call("hget", KEYS[3], member)
      if not proc_ts or tonumber(proc_ts) <= tonumber(ARGV[1]) then
        redis.call("zadd", KEYS[2], "NX", score, member)
        redis.call("zrem", KEYS[1], member)
        redis.call("hdel", KEYS[3], member)
        moved = moved + 1
      end
    end
    return moved
  LUA

  attr_reader :key, :tmp_key, :processing_hash, :backend

  def initialize(key:, **options)
    @key = key
    @tmp_key = "tmp:#{key}"
    @processing_hash = "#{key}:processing_started"
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def enqueue(item)
    backend.with do |connection|
      added = connection.eval(ENQUEUE_SCRIPT, keys: [ key, tmp_key ], argv: [ Time.now.to_f, item ])
      added.to_i == 1
    end
  end

  def dequeue(&)
    item = backend.with do |connection|
      connection.eval(DEQUEUE_SCRIPT, keys: [ key, tmp_key, processing_hash ], argv: [ Time.now.to_f ])
    end

    return if item.blank?

    begin
      yield(item)

      backend.with do |connection|
        connection.multi do |multi|
          multi.zrem(tmp_key, item)
          multi.hdel(processing_hash, item)
        end
      end
    rescue Exception => e
      backend.with do |connection|
        connection.eval(RESCUE_SCRIPT, keys: [ key, tmp_key, processing_hash ], argv: [ item ])
      end

      raise e
    end
  end

  def peek
    backend.with { |connection| connection.zrange(key, 0, 0).first }
  end

  def empty?
    size.zero?
  end

  def size
    backend.with { |connection| connection.zcard(key) }
  end

  def recover!(processing_longer_than:)
    backend.with do |connection|
      connection.eval(RECOVER_SCRIPT, keys: [ tmp_key, key, processing_hash ], argv: [ processing_longer_than.to_f ])
    end
  end
end
