class CommaSeparatedListType < ActiveRecord::Type::String
  def cast(value)
    return value if value.is_a?(Array)

    value.to_s.split(/,\s*/).reject(&:blank?).uniq
  end
end
