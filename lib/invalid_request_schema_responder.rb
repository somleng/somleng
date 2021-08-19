require_relative "application_responder"

class InvalidRequestSchemaResponder < ApplicationResponder
  def display(_resource, given_options = {})
    controller.render(
      given_options.merge!(options, format => json_resource_errors, status: :bad_request)
    )
  end

  def json_resource_errors
    errors = resource.class.error_serializer_class.new(resource).as_json

    Rails.logger.info(errors)

    errors
  end
end
