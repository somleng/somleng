class LATAValidator < ActiveModel::EachValidator
  FORMAT = /\A[1-9]{1}\d{2}\z/

  def validate_each(record, attribute, value)
    return if FORMAT.match?(value)

    record.errors.add(attribute, options.fetch(:message, :invalid))
  end
end
