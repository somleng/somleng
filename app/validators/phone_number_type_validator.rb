class PhoneNumberTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?
    return if record.number.blank?

    parser = options.fetch(:parser) { PhoneNumberParser.new }
    number = parser.parse(record.number)
    valid_types = number.e164? ? PhoneNumber::E164_TYPES : PhoneNumber::SHORT_CODE_TYPES
    return if value.to_sym.in?(valid_types)

    record.errors.add(attribute, :invalid)
  end
end
