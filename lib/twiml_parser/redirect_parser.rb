module TwiMLParser
  class RedirectParser < NodeParser
    attr_reader :action_validator, :method_validator

    def initialize(node, options = {})
      super
      @action_validator = options.fetch(:action_validator, ActionValidator.new)
      @method_validator = options.fetch(:method_validator, MethodValidator.new)
    end

    Result = Struct.new(:url, :method, keyword_init: true) do
      def self.verb
        :redirect
      end
    end

    def parse
      validate!

      Result.new(
        url:,
        method:
      )
    end

    private

    def validate!
      raise(TwiMLError, "Invalid URL: '#{url}'") unless action_validator.valid?(url)
      raise(TwiMLError, "Invalid attribute: 'method'") unless method_validator.valid?(method)
    end

    def url
      node.content.strip
    end

    def method
      attributes["method"].to_s.upcase.presence
    end
  end
end
