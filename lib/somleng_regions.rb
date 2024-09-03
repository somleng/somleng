require_relative "somleng_regions/region"

module SomlengRegions
  class << self
    MOCK_REGIONS = [
      Region.new(
        identifier: "ap-southeast-1",
        alias: "hydrogen",
        group_id: 1,
        human_name: "South East Asia (Singapore)"
      ),
      Region.new(
        identifier: "us-east-1",
        alias: "helium",
        group_id: 2,
        human_name: "North America (Virginia, US)"
      )
    ]

    def configure
      yield(configuration)
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    def regions
      @regions ||= Collection.new(configuration.stub_regions ? MOCK_REGIONS : configuration.region_data.map { |region| Region.new(region) })
    end
  end
end

require_relative "somleng_regions/configuration"
require_relative "somleng_regions/collection"
