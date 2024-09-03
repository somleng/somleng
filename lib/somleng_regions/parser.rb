module SomlengRegions
  class Parser
    def parse(region_data)
      JSON.parse(region_data).map { |region| Region.new(region) }
    end
  end
end
