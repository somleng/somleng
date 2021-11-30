module DecoratableResource
  extend ActiveSupport::Concern

  included do
    delegate :decorator_class, to: :class
  end

  def decorated
    return self if decorator_class.blank?

    decorator_class.new(self)
  end

  module ClassMethods
    def decorator_class
      "#{model_name}Decorator".safe_constantize
    end
  end
end
