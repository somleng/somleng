class ApplicationSerializer
  API_VERSION = "2010-04-01".freeze

  attr_reader :object, :serializer_options

  def initialize(object, serializer_options = {})
    @object = object
    @serializer_options = serializer_options
  end

  def serializable_hash(_options = nil)
    {}
  end

  def as_json(_options = nil)
    serializable_hash.as_json
  end

  private

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end
end
