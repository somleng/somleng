module TwiMLParser
  class NodeParser
    def parse(node)
      build_node(node)
    end

    private

    def build_node(node)
      Node.new(
        attributes: node.attributes.transform_values { |v| v.value.strip },
        name: node.name,
        text?: node.text?,
        children: build_children(node),
        content: node.content
      )
    end

    def build_children(node)
      node.children.each_with_object([]) do |child, result|
        result << build_node(child)
      end
    end
  end
end
