module RequestSchemaHelpers
  def validate_schema(params = {})
    described_class.schema.call(params)
  end
end

RSpec.configure do |config|
  config.include RequestSchemaHelpers, type: :request_schema
end
