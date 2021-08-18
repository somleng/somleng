class APIController < ActionController::API
  self.responder = APIResponder

  respond_to :json

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
    api_namespace = Array(options.delete(:api_namespace))
    if options[:location].respond_to?(:call)
      options[:location] = options.fetch(:location).call(resource)
    end
    respond_with(*api_namespace, :v1, resource, **options)
  end
end
