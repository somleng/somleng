class ApplicationFilter
  attr_reader :resources_scope, :input_params, :scoped_to, :options

  class_attribute :filter_schema, :options

  def self.filter_params(&block)
    self.filter_schema = Dry::Validation.Contract do
      params do
        optional(:filter).schema(&block)
      end
    end
  end

  def initialize(**options)
    @resources_scope = options.fetch(:resources_scope)
    @input_params = options.fetch(:input_params).to_h
    @scoped_to = options.fetch(:scoped_to, {}).symbolize_keys
    @options = options.fetch(:options, {})
  end

  def apply
    resources_scope.scoped_to(scoped_to)
  end

  private

  def filter_params
    result = filter_schema.call(input_params, options: {})
    result.success? ? result.values.fetch(:filter, {}) : {}
  end
end
