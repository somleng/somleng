require "ostruct"

module SomlengRegion
  class Region < OpenStruct
    class RegionNotFound < StandardError; end

    MOCK_REGIONS = [
      new(
        identifier: "ap-southeast-1",
        alias: "hydrogen",
        group_id: 1,
        human_name: "South East Asia (Singapore)"
      ),
      new(
        identifier: "us-east-1",
        alias: "helium",
        group_id: 2,
        human_name: "North America (Virginia, US)"
      )
    ]

    class << self
      def all
        collection
      end

      def find_by(attributes)
        collection.find do |region|
          attributes.all? { |key, value| region[key] == value }
        end
      end

      def find_by!(*)
        find_by(*) || raise(RegionNotFound.new)
      end

      private

      def collection
        @collection ||= config.stub_regions ? MOCK_REGIONS : config.region_data.map { |region| new(region) }
      end

      def config
        SomlengRegion.configuration
      end
    end
  end
end
