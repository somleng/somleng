RSpec::Matchers.define :match_api_response_schema do |schema_name|
  match do |response_body|
    @validator = APIResponseSchemaValidator.new(response_body, schema_name)
    @validator.valid_response?
  end

  failure_message do
    @validator.errors
  end
end

RSpec::Matchers.define :match_api_response_collection_schema do |schema_name|
  match do |response_body|
    @validator = APIResponseSchemaValidator.new(response_body, schema_name)
    @validator.valid_collection?
  end

  failure_message do
    @validator.errors
  end
end

RSpec::Matchers.define :match_verify_api_response_collection_schema do |schema_name|
  match do |response_body|
    @validator = APIResponseSchemaValidator.new(response_body, schema_name)
    @validator.valid_verify_collection?
  end

  failure_message do
    @validator.errors
  end
end

RSpec::Matchers.define :match_jsonapi_resource_schema do |schema_name|
  match do |response_body|
    @validator = JSONAPIResourceSchemaValidator.new(response_body, schema_name)
    @validator.valid_resource?
  end

  failure_message do
    @validator.errors
  end
end

RSpec::Matchers.define :match_jsonapi_resource_collection_schema do |schema_name|
  match do |response_body|
    @validator = JSONAPIResourceSchemaValidator.new(response_body, schema_name)
    @validator.valid_collection?
  end

  failure_message do
    @validator.errors
  end
end

class APIResponseSchemaValidator
  class_attribute :schema_namespace

  self.schema_namespace = "APIResponseSchema"

  attr_reader :data, :schema_path, :errors

  def initialize(data, schema_path)
    @data = data
    @schema_path = schema_path
  end

  def valid_response?
    validate_schema(schema)
  end

  def valid_collection?
    validate_schema(define_collection_schema)
  end

  def valid_verify_collection?
    validate_schema(define_verify_collection_schema)
  end

  private

  def schema
    "#{schema_namespace}::#{schema_class_name}Schema".constantize
  end

  def schema_class_name
    schema_path.to_s.camelize
  end

  def validate_schema(schema_to_validate)
    result = schema_to_validate.call(JSON.parse(data))
    @errors = result.errors.to_h
    result.success?
  end

  def define_collection_schema
    __schema__ = schema
    collection_name = schema_class_name.demodulize.underscore.pluralize.to_sym

    Dry::Schema.JSON do
      required(collection_name).value(:array).each do
        schema(__schema__)
      end
      required(:uri).filled(:str?, format?: %r{\A/})
      required(:page).filled(:int?)
      required(:page_size).filled(:int?)
      required(:first_page_uri).filled(:str?, format?: %r{\A/})
      required(:next_page_uri).maybe(:str?, format?: %r{\A/})
      required(:previous_page_uri).maybe(:str?, format?: %r{\A/})
    end
  end

  def define_verify_collection_schema
    __schema__ = schema
    collection_name = schema_class_name.demodulize.underscore.pluralize.to_sym

    Dry::Schema.JSON do
      required(collection_name).value(:array).each do
        schema(__schema__)
      end
      required(:meta).schema do
        required(:url).filled(:str?, format?: /\Ahttps/)
        required(:page).filled(:int?)
        required(:page_size).filled(:int?)
        required(:first_page_url).filled(:str?, format?: /\Ahttps/)
        required(:next_page_url).maybe(:str?, format?: /\Ahttps/)
        required(:previous_page_url).maybe(:str?, format?: /\Ahttps/)
        required(:key).value(eql?: collection_name.to_s)
      end
    end
  end
end

class JSONAPIResourceSchemaValidator < APIResponseSchemaValidator
  def valid_resource?
    validate_schema(define_resource_schema)
  end

  def valid_collection?
    validate_schema(define_collection_schema)
  end

  private

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
