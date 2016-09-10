class ActiveCallRouterAdapter
  def self.configuration(*keys)
    ENV["active_call_router_#{keys.compact.join('_')}".upcase]
  end

  def self.class_name
    configuration(:class_name)
  end

  def self.instance(*args)
    (class_name && Object.const_defined?(class_name) && class_name.constantize.new(*args)) || Twilreapi::ActiveCallRouter::Base.new(*args)
  end
end
