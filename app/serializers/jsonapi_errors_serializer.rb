class JSONAPIErrorsSerializer
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def serializable_hash(_options = nil)
    errors = object.errors
    errors.each_with_object(errors: []) do |error, result|
      result[:errors] << build_error(error)
    end
  end

  def as_json(_options = nil)
    serializable_hash.as_json
  end

  private

  def build_error(error)
    {
      title: error.message
    }
  end
end
