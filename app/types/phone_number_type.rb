class PhoneNumberType < ActiveRecord::Type::String
  AREA_CODE_COUNTRY_PREFIXES = [ "1" ].freeze

  PhoneNumber = Data.define(:value, :country_code, :area_code, :e164, :sip, :sip_address) do
    def initialize(value:, **)
      super(value:, country_code: nil, area_code: nil, e164: false, sip: false, sip_address: nil, **)
    end

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
      e164? ? ISO3166::Country.find_all_country_by_country_code(country_code) : ISO3166::Country.all
    end

    def country
      possible_countries.first if possible_countries.one?
    end
  end

  attr_reader :validator, :splitter, :preserve_plus_prefix

  def initialize(**options)
    super()
    @validator = options.fetch(:validator) { PhoneNumberValidator.new }
    @splitter = options.fetch(:splitter) { Phony }
    @preserve_plus_prefix = options.fetch(:preserve_plus_prefix, false)
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

    plus_prefix = value.strip.start_with?("+")
    value = value.gsub(/\D/, "")

    return if value.blank?

    if validator.valid?(value)
      country_code, area_code, = splitter.split(value)
      value = "+#{value}" if plus_prefix && preserve_plus_prefix

      PhoneNumber.new(
        value:,
        e164: true,
        country_code:,
        area_code: (area_code if country_code.in?(AREA_CODE_COUNTRY_PREFIXES))
      )
    else
      PhoneNumber.new(value:, e164: false)
    end
  end

  def serialize(value)
    cast(value)&.value
  end
end
