RSpec::Matchers.define :match_response_schema do |schema_name|
  chain :with do |item_schema_name|
    with_options[:item_schema] = resolve_schema(item_schema_name)
  end

  match do |response_body|
    schema = resolve_schema(schema_name)
    @result = schema.with(with_options).call(JSON.parse(response_body, symbolize_names: true))
    @result.success?
  end

  def failure_message
    @result.messages
  end

  def with_options
    @with_options ||= {}
  end

  def resolve_schema(name)
    "ResponseSchema::#{name.to_s.classify}Schema".constantize
  end
end
