require_relative "application_responder"

class ApiResponder < ApplicationResponder
  def display(resource, given_options = {})
    serializer_class = options.delete(:serializer_class) || resource.serializer_class
    serializer_options = options.delete(:serializer_options) || {}
    super(serializer_class.new(resource, serializer_options), given_options)
  end

  def json_resource_errors
    ApiErrorSerializer.new(resource, status_code: 422).as_json
  end
end
