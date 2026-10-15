module FilterableResource
  extend ActiveSupport::Concern

  module ClassMethods
    def filter_class
      "#{model_name}Filter".constantize
    end
  end
end
