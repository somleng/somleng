module TwiMLParser
  class RedirectParser < VerbParser
    attr_reader :action_validator, :method_validator, :uppercase_attribute

    def initialize(options = {})
      super()
      @action_validator = options.fetch(:action_validator, ActionValidator.new)
      @method_validator = options.fetch(:method_validator, MethodValidator.new)
      @uppercase_attribute = options.fetch(:uppercase_attribute, UppercaseAttribute.new)
    end

    Result = Struct.new(:url, :method, keyword_init: true) do
      def self.name
        "Redirect"
      end
    end

    def parse(node)
      super

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
      uppercase_attribute.cast(node.attributes["method"]).presence
    end
  end
end
