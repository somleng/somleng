RSpec::Matchers.define :match_api_response_schema do |schema_name|
  match do |response_body|
    @validator = APIResponseSchemaValidator.new(response_body, schema_name)
    @validator.valid_response?
  end

  failure_message do
    @validator.errors
  end
end

RSpec::Matchers.define :match_api_resource_schema do |schema_name|
  match do |response_body|
    @validator = APIResponseSchemaValidator.new(response_body, schema_name)
    @validator.valid_resource?
  end

  failure_message do
    @validator.errors
  end
end

RSpec::Matchers.define :match_api_resource_collection_schema do |schema_name|
  match do |response_body|
    @validator = APIResponseSchemaValidator.new(response_body, schema_name)
    @validator.valid_collection?
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

  def valid_resource?
    validate_schema(define_resource_schema)
  end

  def valid_collection?
    validate_schema(define_collection_schema)
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

  def define_resource_schema
    __schema__ = schema

    Dry::Schema.JSON do
      required(:data).schema(__schema__)
    end
  end

  def define_collection_schema
    __schema__ = schema

    Dry::Schema.JSON do
      required(:data).value(:array).each do
        schema(__schema__)
      end

      required(:links).schema do
        required(:prev).maybe(:str?)
        required(:next).maybe(:str?)
      end
    end
  end
end
