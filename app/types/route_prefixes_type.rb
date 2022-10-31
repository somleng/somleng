class RoutePrefixesType < ActiveRecord::Type::String
  def cast(value)
    Array(value).join(", ")
  end

  def deserialize(value)
    value.to_s.split(/,\s*/).map { |v| v.gsub(/\D/, "").strip }.reject(&:blank?).uniq
  end
end
