module TwiMLParser
  class MessageParser < VerbParser
    Result = Struct.new(:body, :to, :from, :action, :method, keyword_init: true) do
      def self.name
        "Message"
      end
    end

    attr_reader :action_validator, :method_validator, :uppercase_attribute

    def initialize(options = {})
      super()
      @action_validator = options.fetch(:action_validator, ActionValidator.new)
      @method_validator = options.fetch(:method_validator, MethodValidator.new)
      @uppercase_attribute = options.fetch(:uppercase_attribute, UppercaseAttribute.new)
    end

    def parse(node)
      super

      validate!

      Result.new(
        body: child.content.strip,
        to: node.attributes["to"],
        from: node.attributes["from"],
        action:,
        method:
      )
    end

    private

    def child
      node.children.first
    end

    def validate!
      raise(TwiMLError, "Invalid content: '#{child}'") unless valid_child?
      raise(TwiMLError, "Invalid attribute: 'method'") unless method_validator.valid?(method)
      raise(TwiMLError, "Invalid attribute: 'action'") unless action_validator.valid?(action, allow_blank: true)
    end

    def valid_child?
      child.text? || child.name == "Body"
    end

    def action
      node.attributes["action"]
    end

    def method
      uppercase_attribute.cast(node.attributes["method"]).presence
    end
  end
end
