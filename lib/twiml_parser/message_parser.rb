module TwiMLParser
  class MessageParser < NodeParser
    Result = Struct.new(:body, :to, :from, :action, :method, keyword_init: true) do
      def self.verb
        :message
      end
    end

    attr_reader :action_validator, :method_validator

    def initialize(node, options = {})
      super
      @action_validator = options.fetch(:action_validator, ActionValidator.new)
      @method_validator = options.fetch(:method_validator, MethodValidator.new)
    end

    def parse
      validate!

      Result.new(
        body: child.content,
        to: attributes["to"],
        from: attributes["from"],
        action:,
        method:
      )
    end

    private

    def child
      node.children.first
    end

    def validate!
      raise_error("Invalid content '#{child}'") unless valid_child?
      raise_error("Invalid attribute 'method'") unless method_validator.valid?(method)
      raise_error("Invalid attribute 'action'") unless action_validator.valid?(action, allow_blank: true)
    end

    def valid_child?
      child.text? || child.name == "Body"
    end

    def action
      attributes["action"]
    end

    def method
      attributes["method"].to_s.upcase.presence
    end
  end
end
