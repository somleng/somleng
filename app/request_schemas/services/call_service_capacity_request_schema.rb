module Services
  class CallServiceCapacityRequestSchema < ServicesRequestSchema
    params do
      required(:region).value(:str?, included_in?: SomlengRegion::Region.all.map(&:alias))
      required(:capacity).value(:integer, gteq?: 0)
    end
  end
end
