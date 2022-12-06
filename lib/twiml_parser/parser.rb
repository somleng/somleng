module TwiMLParser
  class Parser
    attr_reader :node_parser, :message_parser, :redirect_parser

    def initialize(options = {})
      @node_parser = options.fetch(:node_parser, NodeParser.new)
      @message_parser = options.fetch(:message_parser, MessageParser.new)
      @redirect_parser = options.fetch(:redirect_parser, RedirectParser.new)
    end

    def parse(twiml)
      twiml_doc(twiml).each_with_object([]) do |verb, result|
        node = node_parser.parse(verb)

        next if verb.comment?

        case verb.name
        when "Message"
          result << message_parser.parse(node)
        when "Redirect"
          result << redirect_parser.parse(node)
        else
          raise TwiMLError, "Invalid element '#{verb.name}'"
        end
      end
    end

    private

    def twiml_doc(twiml)
      doc = ::Nokogiri::XML(twiml.strip) do |config|
        config.options = Nokogiri::XML::ParseOptions::NOBLANKS
      end

      if doc.root.name != "Response"
        raise(TwiMLError, "The root element must be the '<Response>' element")
      end

      doc.root.children
    rescue Nokogiri::XML::SyntaxError => e
      raise TwiMLError, "Error while parsing XML: #{e.message}. XML Document: #{twiml}"
    end
  end
end
