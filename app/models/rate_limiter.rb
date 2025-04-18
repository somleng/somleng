class RateLimiter
  class RateLimitExceededError < StandardError
    attr_reader :seconds_remaining_in_current_window

    def initialize(message, seconds_remaining_in_current_window:)
      super(message)
      @seconds_remaining_in_current_window = seconds_remaining_in_current_window
    end
  end

  class TimeWindow
    attr_reader :duration

    def initialize(duration)
      @duration = duration
      @current_time = current_time_method
    end

    def current
      current_time / duration
    end

    def seconds_remaining
      duration - (current_time % duration)
    end

    def unit
      duration.parts.keys.first
    end

    def to_s
      "#{duration}_seconds"
    end

    private

    def current_time
      @current_time.call
    end

    def current_time_method
      case unit
      when :seconds
        -> { Time.current.sec }
      when :minutes
        -> { Time.current.min }
      when :hours
        -> { Time.current.hour }
      when :days
        -> { Time.current.day }
      else
        raise ArgumentError, "Invalid duration unit: #{unit}"
      end
    end
  end

  attr_reader :key, :rate, :time_window, :backend

  def initialize(**options)
    @key = options.fetch(:key)
    @rate = options.fetch(:rate)
    @time_window = TimeWindow.new(options.fetch(:window_size) { 10.seconds })
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def request!
    window_key = calculate_window_key
    request_count = increment(window_key)

    raise(RateLimitExceededError.new("Rate limit exceeded for key: #{window_key}", seconds_remaining_in_current_window: time_window.seconds_remaining)) if request_count > limit
  end

  private

  def limit
    time_window.duration * rate
  end

  def increment(key)
    count = 0

    backend.with do |connection|
      count, _ = connection.multi do |transaction|
        transaction.incr(key)
        transaction.expire(key, time_window.duration)
      end
    end

    count
  end

  def calculate_window_key
    "#{key}:#{time_window.current}:#{time_window}"
  end
end
