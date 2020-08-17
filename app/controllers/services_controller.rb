class ServicesController < ActionController::API
  self.responder = ApplicationResponder

  respond_to :json
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.configuration.app_settings.fetch(:services_user),
    password: Rails.configuration.app_settings.fetch(:services_password)
  )

  private

  def validate_request_schema(with:, **options, &_block)
    schema_options = options.delete(:schema_options) || {}
    input_params = options.delete(:input_params) || request.request_parameters
    schema = with.new(input_params: input_params, options: schema_options)

    if schema.success?
      resource = yield(schema.output)
      respond_with_resource(resource, options)
    else
      respond_with_resource(schema, responder: InvalidRequestSchemaResponder, **options)
    end
  end

  def respond_with_resource(resource, options = {})
    respond_with(:services, resource, **options)
  end
end
