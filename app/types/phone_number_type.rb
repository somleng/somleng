class PhoneNumberType < ActiveRecord::Type::String
  AREA_CODE_COUNTRY_PREFIXES = [ "1" ].freeze

  PhoneNumber = Struct.new(:value, :country_code, :area_code, :e164, :sip, :sip_address, keyword_init: true) do
    def to_s
      value
    end

    def e164?
      e164
    end

    def sip?
      sip
    end

    def ==(other)
      if other.is_a?(self.class)
        value == other.value
      else
        value == other
      end
    end

    def possible_countries
      @possible_countries ||= e164? ? ISO3166::Country.find_all_country_by_country_code(country_code) : ISO3166::Country.all
    end

    def country
      possible_countries.first if possible_countries.one?
    end
  end

  attr_reader :validator, :splitter

  def initialize(**options)
    super
    @validator = options.fetch(:validator) { PhoneNumberValidator.new }
    @splitter = options.fetch(:splitter) { Phony }
  end

  def cast(value)
    return if value.blank?
    return value if value.is_a?(PhoneNumber)
    if value.strip.start_with?("sip:")
      return PhoneNumber.new(
        value: value.strip,
        sip_address: value.strip.delete_prefix("sip:"),
        sip: true
      )
    end

    value = value.gsub(/\D/, "")

    return if value.blank?

    result = PhoneNumber.new(value:)

    if validator.valid?(value)
      result.e164 = true
      country_code, area_code, = splitter.split(value)
      result.country_code = country_code
      result.area_code = area_code if country_code.in?(AREA_CODE_COUNTRY_PREFIXES)
    else
      result.e164 = false
    end

    result
  end

  def serialize(value)
    cast(value)&.value
  end
end
