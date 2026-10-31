class AlphanumericSenderIDFormatValidator < ActiveModel::EachValidator
  ALLOW_NUMERIC_REGEXP = /\A(?:\+?\d+|(?=.*[A-Za-z])[A-Za-z0-9 +_&\.-]{3,11})\z/
  ALPHA_ONLY_REGEXP = /\A(?=.*[A-Za-z])[A-Za-z0-9 +_&\.-]{3,11}\z/

  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank? && !options.fetch(:allow_blank, false)
    return if value.match?(options.fetch(:allow_numeric, false) ? ALLOW_NUMERIC_REGEXP : ALPHA_ONLY_REGEXP)

    record.errors.add(attribute, options.fetch(:message, :invalid))
  end
end
