class TwilioAPIRequestSchema < ApplicationRequestSchema
  def self.error_serializer_class
    TwilioAPI::RequestErrorsSerializer
  end
end
