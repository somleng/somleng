class TwiMLValidator
  attr_reader :options

  def valid?(value)
    Nokogiri::XML(value) do |c|
      c.options = Nokogiri::XML::ParseOptions::STRICT
    end
  rescue Nokogiri::XML::SyntaxError => _e
    false
  end

  true
end
