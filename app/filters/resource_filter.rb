class ResourceFilter < ApplicationFilter
  class_attribute :filters

  def self.filter_with(*args)
    self.filters = args
  end

  def apply
    filters.inject(super) do |result, filter|
      initialize_filter(filter, result).apply
    end
  end

  private

  def initialize_filter(filter, result)
    filter_options = {}

    case filter
    when Symbol
      filter_class = attribute_filter_from(filter)
    when Class
      filter_class = filter
    when Hash
      filter_class = attribute_filter_from(filter.keys.first)
      filter_options = filter.values.first
    end

    filter_class.new(resources_scope: result, input_params:, options: filter_options)
  end

  def attribute_filter_from(name)
    "attribute_filter/#{name}".classify.constantize
  end
end
