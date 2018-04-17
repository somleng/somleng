# frozen_string_literal: true

class ActiveBillerAdapter
  def self.configuration(*keys)
    ENV["active_biller_#{keys.compact.join('_')}".upcase]
  end

  def self.class_name
    configuration(:class_name)
  end

  def self.instance(*args)
    default_class = Twilreapi::ActiveBiller::Base
    return default_class.new(*args) unless class_name
    return default_class.new(*args) unless Object.const_defined?(class_name)
    class_name.constantize.new(*args)
  end
end
