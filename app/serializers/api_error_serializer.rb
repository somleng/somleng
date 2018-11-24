class ApiErrorSerializer
  attr_accessor :serializable, :status_code

  def initialize(serializable, options = {})
    self.serializable = serializable
    self.status_code = options[:status_code]
  end

  def serializable_hash(_options = nil)
    errors = serializable.errors
    message = serializable.errors(full: true).map { |_k, attribute_errors| attribute_errors.to_sentence }.to_sentence

    {
      errors: errors,
      status: status_code,
      message: message
    }.compact
  end

  def as_json(_options = nil)
    serializable_hash.as_json
  end
end
