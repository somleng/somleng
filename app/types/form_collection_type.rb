class FormCollectionType < ActiveRecord::Type::Value
  attr_reader :form, :reject_if

  def initialize(form:, reject_if: nil, **)
    @form = form
    @reject_if = reject_if
    super(**)
  end

  def cast(value)
    return value if value.is_a?(FormCollection)

    items = if value.is_a?(Hash)
      value.values.any? { _1.is_a?(Hash) } ? value.values : [ value ]
    else
      value
    end

    items = items.each_with_object([]) do |item, result|
      next if item.blank?

      if item.is_a?(Hash)
        next if reject_if.present? && reject_if.call(item)
        result << item
      elsif item.respond_to?(:attributes)
        result << form.initialize_with(item)
      end
    end

    FormCollection.new(items, form:)
  end
end
