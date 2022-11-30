module TwiMLParser
  class Parser
    attr_reader :twiml

    def initialize(twiml)
      @twiml = twiml
    end

    def parse
      twiml_doc.each_with_object([]) do |verb, result|
        next if verb.comment?

        case verb.name
        when "Message"
          result << MessageParser.new(verb).parse
        when "Redirect"
          result << RedirectParser.new(verb).parse
        else
          raise TwiMLError, "Invalid element '#{verb.name}'"
        end
      end
    end

    private

    def twiml_doc
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
