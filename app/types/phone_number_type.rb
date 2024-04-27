class PhoneNumberType < ActiveRecord::Type::String
  PhoneNumber = Struct.new(:value, :country_code, :e164, keyword_init: true) do
    def to_s
      value
    end

    def e164?
      e164
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

    value = value.gsub(/\D/, "")

    result = PhoneNumber.new(value:)

    if validator.valid?(value)
      result.e164 = true
      result.country_code = splitter.split(value).first
    else
      result.e164 = false
    end

    result
  end

  def serialize(value)
    cast(value)&.value
  end
end
