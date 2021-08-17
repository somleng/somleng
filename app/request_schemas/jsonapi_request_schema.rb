class JSONAPIRequestSchema < ApplicationRequestSchema
  option :resource, optional: true

  def self.attribute_rule(*args, &block)
    args = args.first if args.one?
    rule(data: { attributes: args }) do
      attributes = values.dig(:data, :attributes)
      instance_exec(attributes, &block) if block_given?
    end
  end

  def self.relationship_rule(name, &block)
    rule(data: { relationships: { name => { data: :id } } }, &block)
  end

  def self.error_serializer_class
    JSONAPIRequestErrorsSerializer
  end

  rule(:data) do
    if resource.present?
      resource_id = values.fetch(:data)[:id]
      if resource_id.blank?
        key("data.id").failure("is missing")
      elsif resource_id != resource.id
        key("data.id").failure("is invalid")
      end
    end
  end

  def output
    output_data = super
    result = output_data.dig(:data, :attributes)

    output_data.fetch(:data).fetch(:relationships, {}).each do |relationship, relationship_data|
      result[relationship] = relationship_data.dig(:data, :id)
    end

    result
  end

  private

  def attribute_key_path(name)
    { data: { attributes: name } }
  end
end
