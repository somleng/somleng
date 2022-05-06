class HostnameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if "https://#{value}" =~ /\A#{URI::DEFAULT_PARSER.make_regexp(%w[https])}\z/

    record.errors.add(attribute, options.fetch(:message, :invalid))
  end
end
