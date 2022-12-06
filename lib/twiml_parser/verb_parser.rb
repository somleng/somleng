module TwiMLParser
  class VerbParser
    def parse(node)
      @node = node
    end

    private

    attr_reader :node
  end
end
