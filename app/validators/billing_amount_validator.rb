class BillingAmountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?

    billing_currency = options.fetch(:billing_currency).call(record)
    currency_attribute = options.fetch(:currency_attribute, :currency)
    currency_value = record.public_send(currency_attribute)

    return record.errors.add(currency_attribute, :blank) if currency_value.blank?
    record.errors.add(currency_attribute, :invalid) if currency_value != billing_currency
  end
end
