class ApplicationFilter
  attr_reader :resources_scope, :input_params, :scoped_to

  class_attribute :filter_schema

  def self.filter_params(&block)
    self.filter_schema = Dry::Validation.Contract do
      params do
        optional(:filter).schema(&block)
      end
    end
  end

  def initialize(resources_scope:, input_params:, scoped_to: {})
    @resources_scope = resources_scope
    @input_params = input_params.to_h
    @scoped_to = scoped_to.symbolize_keys
  end

  def apply
    resources_scope.where(scoped_to)
  end

  private

  def filter_params
    result = filter_schema.call(input_params)
    result.success? ? result.values.fetch(:filter, {}) : {}
  end
end
