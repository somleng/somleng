class PhoneNumberParser
  PhoneNumber = Struct.new(:number, :country_code, :country, :possible_countries, keyword_init: true)

  attr_reader :validator, :splitter

  def initialize(options = {})
    @validator = options.fetch(:validator) { PhoneNumberValidator.new }
    @splitter = options.fetch(:splitter) { Phony }
  end

  def self.parse(*args, **options)
    new(options).parse(*args)
  end

  def parse(number)
    result = PhoneNumber.new(number:)

    return result unless validator.valid?(number)

    result.country_code = splitter.split(number).first
    result.possible_countries = ISO3166::Country.find_all_country_by_country_code(result.country_code)
    result.country = result.possible_countries.first if result.possible_countries.one?

    result
  end
end
