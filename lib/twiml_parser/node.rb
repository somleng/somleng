module TwiMLParser
  Node = Struct.new(:attributes, :name, :text?, :children, :content, keyword_init: true) do
    def to_s
      content
    end
  end
end
