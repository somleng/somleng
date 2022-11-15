class PhoneNumberFormatter
  attr_reader :formatter

  def initialize(formatter: Phony)
    @formatter = formatter
  end

  def format(value, options = {})
    return value unless formatter.plausible?(value)

    if options[:format] == :e164
      "+#{value}"
    else
      formatter.format(value, options)
    end
  end
end
