class NestedFormValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    form = options.fetch(:form) { record.public_send(attribute) }

    return if form.blank?
    return if form.valid?

    form.errors.each do |error|
      record.errors.add(:"#{attribute}.#{error.attribute}", error.message)
    end
  end
end
