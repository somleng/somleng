class TwilioAPIRequestSchema < ApplicationRequestSchema
  def self.error_serializer_class
    TwilioAPIRequestErrorsSerializer
  end
end
