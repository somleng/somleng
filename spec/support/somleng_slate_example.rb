class SomlengSlateExample < RspecApiDocumentation::Views::SlateExample
  def initialize(example, configuration)
    super
    self.template_path = File.expand_path(__dir__)
  end

  def requests
    super.map do |hash|
      hash[:request_query_parameters_text] = JSON.pretty_generate(hash[:request_query_parameters]) if hash[:request_query_parameters].present?
      hash
    end
  end
end
