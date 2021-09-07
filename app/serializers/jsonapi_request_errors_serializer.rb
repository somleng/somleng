class JSONAPIRequestErrorsSerializer
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def serializable_hash(_options = nil)
    errors = object.errors
    errors.each_with_object(errors: []) do |message, result|
      result[:errors] << {
        title: message.text,
        source: { pointer: "/" + message.path.join("/") },
        **message.meta.slice(:code, :detail)
      }
    end
  end

  def as_json(_options = nil)
    serializable_hash.as_json
  end
end
