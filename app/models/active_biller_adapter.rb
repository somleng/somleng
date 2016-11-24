class ActiveBillerAdapter
  def self.configuration(*keys)
    ENV["active_biller_#{keys.compact.join('_')}".upcase]
  end

  def self.class_name
    configuration(:class_name)
  end

  def self.instance(*args)
    (class_name && Object.const_defined?(class_name) && class_name.constantize.new(*args)) || Twilreapi::ActiveBiller::Base.new(*args)
  end
end
