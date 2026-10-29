class OriginatorIDBehaviorValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    passthrough = options.fetch(:passthrough?)
    passthrough = passthrough.call(record) if passthrough.respond_to?(:call)

    return record.errors.add(attribute, :present) if value.present? && passthrough
    record.errors.add(attribute, :blank) if value.blank? && !passthrough
  end
end
