class ApplicationSerializer
  attr_reader :object, :serializer_options

  def initialize(object, serializer_options = {})
    @object = object
    @serializer_options = serializer_options
  end

  def as_json(_options = nil)
    serializable_hash.as_json
  end
end
