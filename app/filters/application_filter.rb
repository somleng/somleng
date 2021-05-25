class ApplicationFilter
  attr_reader :resources_scope, :input_params

  class_attribute :filter_schema

  def self.filter_params(&block)
    self.filter_schema = Dry::Validation.Contract do
      params do
        optional(:filter).schema(&block)
      end
    end
  end

  def initialize(resources_scope:, input_params:)
    @resources_scope = resources_scope
    @input_params = input_params.to_h
  end

  def apply
    resources_scope
  end

  private

  def filter_params
    result = filter_schema.call(input_params)
    result.success? ? result.values.fetch(:filter, {}) : {}
  end
end
