# frozen_string_literal: true

class ActiveBillerAdapter
  def self.instance(*args)
    default_class = Twilreapi::ActiveBiller::Base
    class_name = Rails.application.secrets[:active_biller_class_name]
    return default_class.new(*args) unless class_name
    return default_class.new(*args) unless Object.const_defined?(class_name)
    class_name.constantize.new(*args)
  end
end
