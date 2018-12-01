module API
  class ErrorSerializer
    attr_accessor :serializable, :status_code

    def initialize(serializable, options = {})
      self.serializable = serializable
      self.status_code = options[:status_code]
    end

    def serializable_hash(_options = nil)
      {
        errors: serializable.errors,
        status: status_code,
        message: error_message
      }.compact
    end

    def as_json(_options = nil)
      serializable_hash.as_json
    end

    private

    def error_message
      messages = if serializable.errors.respond_to?(:full_messages)
                   serializable.errors.full_messages
                 else
                   serializable.errors(full: true).map { |_k, attribute_errors| attribute_errors.to_sentence }
                 end
      messages.to_sentence
    end
  end
end
