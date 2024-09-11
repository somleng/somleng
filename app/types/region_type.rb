class RegionType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?
    return value if value.is_a?(SomlengRegion::Region)

    SomlengRegion::Region.find_by(alias: value.to_s)
  end

  def serialize(value)
    cast(value)&.alias
  end
end
