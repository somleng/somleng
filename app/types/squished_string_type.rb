class SquishedStringType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    value.squish
  end
end
