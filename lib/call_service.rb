module CallService
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

require_relative "call_service/configuration"
require_relative "call_service/client"
require_relative "call_service/response"
