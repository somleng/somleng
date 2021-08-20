class ServicesRequestSchema < ApplicationRequestSchema
  def self.error_serializer_class
    Services::RequestErrorsSerializer
  end
end
