class URLFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]

    allowed_schemes = options.fetch(:schemes, ["https"])
    allowed_schemes << "http" if options[:allow_http]
    format = options.fetch(:format) { /\A#{URI::DEFAULT_PARSER.make_regexp(allowed_schemes)}\z/ }
    return if value =~ format

    record.errors.add(attribute, options.fetch(:message, :invalid))
  end
end
