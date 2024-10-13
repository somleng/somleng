class RoutePrefixesType < CommaSeparatedListType
  def deserialize(value)
    super.map { |v| v.gsub(/\D/, "").strip }.reject(&:blank?).uniq
  end
end
