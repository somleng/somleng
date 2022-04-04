class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value =~ User::EMAIL_FORMAT

    record.errors.add(attribute, options.fetch(:message, :invalid))
  end
end
