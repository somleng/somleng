class URLFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    validator = options.fetch(:validator) { URLValidator.new(options) }
    return if validator.valid?(value)

    record.errors.add(attribute, options.fetch(:message, :invalid))
  end
end
