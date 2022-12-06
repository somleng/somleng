require "rails_helper"

module TwiMLParser
  RSpec.describe MessageParser do
    it "parses a message verb" do
      node = build_node(
        children: [
          build_node(name: "Body", content: "Body Text")
        ],
        attributes: {
          "to" => "+85512333333",
          "from" => "+85512444444",
          "action" => "/status_callback.xml",
          "method" => "post"
        }
      )
      parser = MessageParser.new

      result = parser.parse(node)

      expect(result).to have_attributes(
        body: "Body Text",
        to: "+85512333333",
        from: "+85512444444",
        action: "/status_callback.xml",
        method: "POST"
      )
    end

    it "handles text in the body" do
      node = build_node(
        children: [
          build_node(content: "Body Text", text?: true, name: nil)
        ]
      )
      parser = MessageParser.new

      result = parser.parse(node)

      expect(result.body).to eq("Body Text")
    end

    it "validates the body" do
      node = build_node(
        children: [
          build_node(name: "Foo", content: "Body Text")
        ]
      )
      parser = MessageParser.new

      expect { parser.parse(node) }.to raise_error(
        TwiMLError, /Invalid content/
      )
    end

    it "validates the action attribute" do
      node = build_node(
        attributes: {
          "action" => "ftp://www.example.com"
        }
      )
      parser = MessageParser.new

      expect { parser.parse(node) }.to raise_error(
        TwiMLError, /Invalid attribute: 'action'/
      )
    end

    it "validates the method attribute" do
      node = build_node(
        attributes: {
          "method" => "HEAD"
        }
      )
      parser = MessageParser.new

      expect { parser.parse(node) }.to raise_error(
        TwiMLError, /Invalid attribute: 'method'/
      )
    end

    def build_node(params = {})
      params.reverse_merge!(
        name: "Message",
        attributes: {}
      )
      params[:children] ||= [
        build_node(name: nil, text?: true, content: "Hello world", children: [])
      ]

      Node.new(params)
    end
  end
end
