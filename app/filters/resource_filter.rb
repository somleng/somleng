class ResourceFilter < ApplicationFilter
  class_attribute :filters

  def self.filter_with(*args)
    self.filters = args
  end

  def apply
    filters.inject(super) do |result, filter|
      filter.new(resources_scope: result, input_params: input_params).apply
    end
  end
end
