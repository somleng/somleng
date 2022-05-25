class SubdomainValidator < ActiveModel::EachValidator
  MIN_LENGTH = 3

  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?
    return record.errors.add(attribute, :too_short, count: MIN_LENGTH) if value.length < MIN_LENGTH

    scope = options.fetch(:scope) { ->(_) { Carrier } }
    return unless scope.call(record).exists?(subdomain: value)

    record.errors.add(attribute, :taken)
  end
end
