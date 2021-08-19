class ServicesRequestSchema < ApplicationRequestSchema
  def self.error_serializer_class
    APIErrorsSerializer
  end
end
