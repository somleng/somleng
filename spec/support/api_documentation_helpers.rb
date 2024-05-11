module APIDocumentationHelpers
  def client
    @client ||= APIDocumentationClient.new(self)
  end
end

RSpec.configure do |config|
  config.prepend(APIDocumentationHelpers, api_doc_dsl: :resource)
end
