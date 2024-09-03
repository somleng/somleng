class RegionType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?
    return value if value.is_a?(SomlengRegions::Region)

    SomlengRegions.regions.find_by(alias: value)
  end

  def serialize(value)
    cast(value)&.alias
  end
end
