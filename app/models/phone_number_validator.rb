class PhoneNumberValidator
  attr_reader :validator

  def initialize(validator: Phony)
    @validator = validator
  end

  def valid?(value)
    return false if value.starts_with?("0")

    validator.plausible?(value)
  end

  def country_code_for(value)
    validator.split(value).first
  end
end
