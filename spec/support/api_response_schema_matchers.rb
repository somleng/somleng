RSpec::Matchers.define :match_api_response_schema do |schema_name|
  match do |response_body|
    @validator = APIResponseSchemaValidator.new(response_body, schema_name)
    @validator.valid_response?
  end

  failure_message do
    @validator.errors
  end
end

class APIResponseSchemaValidator
  attr_reader :data, :schema, :errors

  def initialize(data, schema_name)
    @data = data
    @schema = resolve_schema(schema_name)
  end

  def valid_response?
    validate_schema(schema)
  end

  private

  def resolve_schema(name)
    "APIResponseSchema::#{name.to_s.camelize}Schema".constantize
  end

  def validate_schema(schema_to_validate)
    result = schema_to_validate.call(JSON.parse(data))
    @errors = result.errors.to_h
    result.success?
  end
end
