class ApplicationSerializer
  attr_reader :object, :serializer_options

  def initialize(object, serializer_options = {})
    @object = object
    @serializer_options = serializer_options
  end

  def serializable_hash(_options = nil)
    {
      api_version: "2010-04-01"
    }
  end

  def as_json(_options = nil)
    serializable_hash.as_json
  end
end
