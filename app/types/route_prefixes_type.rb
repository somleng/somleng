class RoutePrefixesType < CommaSeparatedListType
  def cast(value)
    super.map { |v| v.gsub(/\D/, "").strip }.reject(&:blank?).uniq
  end
end
