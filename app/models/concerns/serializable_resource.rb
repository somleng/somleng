module SerializableResource
  extend ActiveSupport::Concern

  included do
    delegate :jsonapi_serializer_class, to: :class
  end

  module ClassMethods
    def jsonapi_serializer_class
      "CarrierAPI::#{model_name}Serializer".constantize
    end

    def csv_serializer_class
      "CSVSerializer::#{model_name}Serializer".constantize
    end
  end
end
