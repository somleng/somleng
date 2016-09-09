class ActiveCallRouter
  attr_accessor :source, :destination

  def initialize(source, destination)
    self.source = source
    self.destination = destination
  end

  def self.configuration(*keys)
    ENV["active_call_router_#{keys.compact.join('_')}".upcase]
  end

  def self.class_name
    configuration(:class_name)
  end

  def self.instance(source, destination)
    (class_name && Object.const_defined?(class_name) && class_name.constantize.new(source, destination)) || self.new(source, destination)
  end

  def routing_instructions
    {"destination" => destination}
  end
end
