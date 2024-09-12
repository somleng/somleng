require "ostruct"

module SomlengRegion
  class Region < OpenStruct
    class RegionNotFound < StandardError; end

    MOCK_REGIONS = [
      new(
        identifier: "ap-southeast-1",
        alias: "hydrogen",
        group_id: 1,
        human_name: "South East Asia (Singapore)",
        nat_ip: "13.250.230.15"
      ),
      new(
        identifier: "us-east-1",
        alias: "helium",
        group_id: 2,
        human_name: "North America (N. Virginia, USA)",
        nat_ip: "52.4.242.134"
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

    def to_s
      self[:alias]
    end

    def ==(other)
      if other.is_a?(self.class)
        self[:alias] == other.alias
      else
        self[:alias] == other
      end
    end
  end
end
