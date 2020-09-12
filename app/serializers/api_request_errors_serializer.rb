class APIRequestErrorsSerializer < ApplicationSerializer
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
end
