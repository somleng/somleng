require "rails_helper"

module TwiMLParser
  RSpec.describe RedirectParser do
    it "parses a redirect verb" do
      node = build_node(
        content: "/status_callback.xml",
        attributes: {
          "method" => "get"
        }
      )
      parser = RedirectParser.new

      result = parser.parse(node)

      expect(result).to have_attributes(
        url: "/status_callback.xml",
        method: "GET"
      )
    end

    it "validates the url" do
      node = build_node(content: "ftp://www.example.com")
      parser = RedirectParser.new

      expect { parser.parse(node) }.to raise_error(
        TwiMLError, /Invalid URL/
      )
    end

    it "validates the method" do
      node = build_node(
        attributes: {
          "method" => "HEAD"
        }
      )
      parser = RedirectParser.new

      expect { parser.parse(node) }.to raise_error(
        TwiMLError, /Invalid attribute: 'method'/
      )
    end

    def build_node(params = {})
      params.reverse_merge!(
        name: "Redirect",
        attributes: {},
        content: "/status_callback.xml"
      )

      Node.new(params)
    end
  end
end
