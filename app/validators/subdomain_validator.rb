class SubdomainValidator < ActiveModel::EachValidator
  RESTRICTED_SUBDOMAINS = %w[
    api mail scfm docs dashboard switch somleng app www
  ].freeze

  MIN_LENGTH = 4

  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?
    return record.errors.add(attribute, :too_short, count: MIN_LENGTH) if value.length < MIN_LENGTH
    return record.errors.add(attribute, :exclusion) if value.in?(RESTRICTED_SUBDOMAINS)

    scope = options.fetch(:scope) { ->(_) { Carrier } }
    return unless scope.call(record).exists?(subdomain: value)

    record.errors.add(attribute, :taken)
  end
end
