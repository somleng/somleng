require_relative "application_responder"

class APIResponder < ApplicationResponder
  def display(resource, given_options = {})
    serializer_class = options.delete(:serializer_class) || resolve_serializer(resource)
    serializer_options = options.delete(:serializer_options) || {}
    super(serializer_class.new(resource, serializer_options), given_options)
  end

  def json_resource_errors
    API::ErrorSerializer.new(resource, status_code: 422).as_json
  end

  private

  def resolve_serializer(resource)
    "API::#{resource.model_name}Serializer".constantize
  end
end
