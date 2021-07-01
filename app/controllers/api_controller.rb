class APIController < ActionController::API
  self.responder = APIResponder

  respond_to :json

  private

  def validate_request_schema(with:, **options, &_block)
    schema = initialize_schema(with: with, **options)

    if schema.success?
      resource = yield(schema.output)
      respond_with_resource(resource, options)
    else
      respond_with_error(schema, options)
    end
  end

  def initialize_schema(with:, **options)
    schema_options = options.delete(:schema_options) || {}
    input_params = options.delete(:input_params) || request.request_parameters
    with.new(input_params: input_params, options: schema_options)
  end

  def respond_with_resource(resource, options = {})
    respond_with(resource, **options)
  end

  def respond_with_error(schema, options = {})
    respond_with(schema, responder: InvalidRequestSchemaResponder, **options)
  end
end
