
module SomlengRegion
  class << self
    def configure
      yield(configuration)
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration
  end
end

require_relative "somleng_region/configuration"
require_relative "somleng_region/region"
