class CommaSeparatedListType < ActiveRecord::Type::String
  def cast(value)
    value.to_s.split(/,\s*/).reject(&:blank?).uniq
  end

  def deserialize(value)
    Array(value).join(", ")
  end
end
