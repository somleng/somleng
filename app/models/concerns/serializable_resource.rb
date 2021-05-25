module SerializableResource
  extend ActiveSupport::Concern

  included do
    delegate :serializer_class, to: :class
  end

  module ClassMethods
    def serializer_class
      "#{model_name}Serializer".constantize
    end

    def csv_serializer_class
      "CSVSerializer::#{model_name}Serializer".constantize
    end
  end
end
