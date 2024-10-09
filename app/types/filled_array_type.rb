class FilledArrayType < ActiveRecord::Type::String
  attr_reader :unique

  def initialize(**options)
    @unique = options.delete(:unique) || false
    super
  end

  def cast(value)
    result = Array(value).reject(&:blank?)
    result = result.uniq if unique
    result
  end
end
