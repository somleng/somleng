module DecoratableResource
  extend ActiveSupport::Concern

  included do
    delegate :decorator_class, to: :class
  end

  module ClassMethods
    def decorator_class
      "#{model_name}Decorator".safe_constantize
    end
  end
end
