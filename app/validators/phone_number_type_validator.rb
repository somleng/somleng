class PhoneNumberTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?
    return if record.number.blank?
    return if value.to_sym.in?(record.number.e164? ? PhoneNumber::E164_TYPES : PhoneNumber::SHORT_CODE_TYPES)

    record.errors.add(attribute, :invalid)
  end
end
