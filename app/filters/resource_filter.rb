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
    case filter
    when Symbol
      filter_class = "attribute_filter/#{filter}".classify.constantize
    when Class
      filter_class = filter
    end

    filter_class.new(resources_scope: result, input_params:)
  end
end
