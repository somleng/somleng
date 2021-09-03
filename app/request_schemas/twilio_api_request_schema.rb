class TwilioAPIRequestSchema < ApplicationRequestSchema
  option :account

  def self.error_serializer_class
    TwilioAPI::RequestErrorsSerializer
  end
end
