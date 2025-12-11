class CallServiceCapacity
  class Instance
    attr_reader :backend

    def initialize(**options)
      @backend = options.fetch(:backend) { AppSettings.redis }
    end

    def current_for(region)
      backend.with do |connection|
        connection.exists?(capacity_key(region)) ? connection.get(capacity_key(region)).to_i : 1
      end
    end

    def set_for(region, capacity:)
      backend.with do |connection|
        connection.set(capacity_key(region), capacity.to_i)
      end
    end

    private

    def capacity_key(region)
      "{call_service_capacity}:#{region}"
    end
  end

  class << self
    def current_for(...)
      Instance.new.current_for(...)
    end

    def set_for(...)
      Instance.new.set_for(...)
    end
  end
end
