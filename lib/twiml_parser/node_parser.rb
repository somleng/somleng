module TwiMLParser
  class NodeParser
    attr_reader :node, :options

    def initialize(node, options = {})
      @node = node
      @options = options
    end

    private

    def attributes
      node.attributes.transform_values { |v| v.value.strip }
    end

    def raise_error(message)
      raise(TwiMLError, message)
    end
  end
end
