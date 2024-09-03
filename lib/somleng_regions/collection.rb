module SomlengRegions
  class Collection
    class RegionNotFoundError < StandardError; end

    attr_reader :regions

    def initialize(regions)
      @regions = regions
    end

    def all
      regions
    end

    def find_by(attributes)
      regions.find do |region|
        attributes.all? { |key, value| region[key] == value }
      end
    end

    def find_by!(*)
      find_by(*) || raise(RegionNotFoundError.new)
    end
  end
end
