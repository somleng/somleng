class FilledArrayType < ActiveRecord::Type::String
  def cast(value)
    Array(value).reject(&:blank?)
  end
end
