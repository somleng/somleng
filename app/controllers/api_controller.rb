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
      respond_with_errors(schema, **options)
    end
  end

  def respond_with_resource(resource, options = {}, &block)
    respond_with(resource, **options, &block)
  end

  def respond_with_errors(object, **options)
    respond_with(object, responder: InvalidRequestSchemaResponder, **options)
  end
end
