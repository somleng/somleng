class PhoneNumberFormatter
  attr_reader :formatter

  def initialize(formatter: Phony)
    @formatter = formatter
  end

  def format(value, options = {})
    return value if value.blank?
    return value.to_s unless value.e164?

    if options[:format] == :e164
      "+#{value}"
    else
      formatter.format(value.to_s, options)
    end
  end
end
