class PhoneNumberType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    value.gsub(/\D/, "")
  end
end
